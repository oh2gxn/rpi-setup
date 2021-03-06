--
-- xmonad.hs 
--
-- Author: Janne Toivola
-- Parts borrowed from Christian Gogolin
--


import XMonad
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- EZConfig could be used for adding Emacs style key bindings
--import XMonad.Util.EZConfig


-- The preferred programs
-- myTerminal      = "konsole"
-- myTerminal      = "xterm"
-- myTerminal      = "gnome-terminal" -- Ubuntu default?
myTerminal      = "urxvt"
myEditor        = "emacs"


-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


-- Width of the window border in pixels.
myBorderWidth   = 3


-- modMask lets you specify which modkey you want to use. 
-- mod1Mask "left alt", the default, but used by Emacs and keyboard layout switch
-- mod2Mask "num lock" by default(?), but remapping to "caps lock" doesn't work
-- mod3Mask "right alt", but used for typing @£${[]}\€ etc. on fi keyboard
-- mod4Mask "windows key" usually, but does not work on NanoX keyboard
myModMask       = mod4Mask


-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
myWorkspaces    = ["term","code","web","mail","pdf"] ++ map show [6..9]



-- Color setup
myActiveForegroudColor = "#000000"
myActiveBackgroudColor = "#ffffff"
myActiveBorderColor = "#00aa00"

myActiveTitleForegroudColor = "#ffffff"
myActiveTitleBackgroudColor = "#000000"
myActiveTitleBorderColor = "#1b87cb"

myInactiveForegroudColor = "#aaaaaa"
myInactiveBackgroundColor = "#000000"
myInactiveBorderColor = "#aaaaaa"

myUrgentForegroudColor = "#ff0000"
myUrgentBackgroudColor = "#111111"
myUrgentBorderColor = "#ff0000"


---------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
-- NOTE: removing a binding from this list disables the binding, 
-- so don't remove the focus and quitting stuff!
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
 
    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
 
    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")
 
    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)
 
     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)
 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)
 
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)



    -- <janne>
    -- Rotate screen left (absolute, 90 deg CCW from normal)
    , ((modm		     , xK_a     ), spawn "xrandr -o left" )

    -- Rotate screen back to normal
    , ((modm		     , xK_s     ), spawn "xrandr -o normal" )

    -- Rotate screen right (absolute, 90 deg CW from normal)
    , ((modm		     , xK_d     ), spawn "xrandr -o right" )
    -- FIXME: Rotate wallpaper too?
    -- </janne>


 
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
 
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
 
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
 
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)



    -- <janne>
    -- Lock the screen with mod-shift-l
    , ((modm .|. shiftMask, xK_l), spawn "slock" )

    -- Lock the screen with pause/break
    , ((0, xK_Pause), spawn "slock" )

    -- Swap keyboard layout between fi and ru with Alt-space
    , ((mod1Mask, xK_space), spawn "setxkbmap -option '' -layout 'fi,ru' -option 'grp:alt_space_toggle'")
    -- </janne>


 
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
 
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
 
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
 
    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++
 
    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
 
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
 
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]




------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
-- Run xmonad with the settings you specify. No need to modify this.
--

main = do

-- Set the background image
   spawn "hsetroot -fill ~/.xmonad/wallpaper"

-- Rotate screen by default?
--   spawn "xrandr -o left"

-- Start xmonad
   xmonad $ defaultConfig {
     terminal           = myTerminal,
     focusFollowsMouse  = myFocusFollowsMouse,
     borderWidth        = myBorderWidth,
     modMask            = myModMask,
     workspaces         = myWorkspaces,
     normalBorderColor  = myInactiveBorderColor,
     focusedBorderColor = myActiveBorderColor,
     keys               = myKeys,
     mouseBindings      = myMouseBindings
   }


-----------------------------
-- My original minimal config
--
--main = xmonad defaultConfig
--         { modMask = mod4Mask
--         }

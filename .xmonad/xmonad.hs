import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

sayMessage :: String -> IO ()
sayMessage message= spawn ("notify-send '" ++  message ++ "'")

myModMask :: KeyMask
myModMask = mod4Mask

main :: IO ()
main = do
  sayMessage "xmonad has been recompiled."
  xmonad $ defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  layoutHook defaultConfig
    , borderWidth = 1
    , terminal = "urxvt"
    , normalBorderColor = "#053569"
    , focusedBorderColor = "#0954B5"
    , modMask = myModMask
    , focusFollowsMouse = False } `additionalKeys`
    [ ((mod1Mask, xK_l), spawn "xlock -mode mountain")
    , ((mod1Mask, xK_Print), spawn "sleep 0.2; beep; scrot")]

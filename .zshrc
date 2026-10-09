# All real config lives in ~/.config/zsh/zshrc.zsh and ~/.config/shell/ (shared with bash).
# Installers that append to this file still work; move anything they add into ~/.config/shell/.
source ~/.config/zsh/zshrc.zsh

# >>> otty shell integration >>>
# Added by Otty — toggle in Settings > Shell > Shell Integration.
# Inert unless launched by Otty (it sets $OTTY_SHELL_INTEGRATION).
if [ -n "$OTTY_SHELL_INTEGRATION" ] && [ -r "$OTTY_SHELL_INTEGRATION/otty-integration.zsh" ]; then
  . "$OTTY_SHELL_INTEGRATION/otty-integration.zsh"
fi
# <<< otty shell integration <<<

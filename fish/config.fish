if status is-interactive
    # Commands to run in interactive sessions can go here
    alias ls="lsd -a"
    alias cat="bat"
    set fish_greeting
    neofetch --colors 219 231 12 219 45 --underline_char '  ' --separator ' '
end

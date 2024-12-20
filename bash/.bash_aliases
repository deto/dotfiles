alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour

# Some shortcuts for different directory listings
alias ls='ls -hF --color=tty'                 # classify files in colour
alias ll='ls -l'                              # long list

alias tree='tree -C' #Automatically use color

alias ssh='ssh -X' #Automatically enable X11 forwarding

alias vim='nvim -u ~/.config/nvim/init_minimal.vim'

alias gradle='JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 gradle'

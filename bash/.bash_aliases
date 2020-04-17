alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour

# Some shortcuts for different directory listings
alias ls='ls -hF --color=tty'                 # classify files in colour
alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #

alias tree='tree -C' #Automatically use color

# This is used to strip outputs/metadata out of jupyter notebook files
alias nbstrip_jq="jq-linux64 --indent 1 \
    '(.cells[] | select(has(\"outputs\")) | .outputs) = []  \
    | (.cells[] | select(has(\"execution_count\")) | .execution_count) = null  \
    | .metadata = {\"language_info\": {\"name\": \"python\", \"pygments_lexer\": \"ipython3\"}} \
    | .cells[].metadata = {} \
    '"

alias ssh='ssh -X' #Automatically enable X11 forwarding
alias bigjob='qsub -q yosef3 -d $(pwd) -l nodes=1:ppn=20 -l walltime=336:00:00 -l cput=9999:00:00 -V' # Submit a big job in current directory
alias bigjob_noV='qsub -q yosef3 -d $(pwd) -l nodes=1:ppn=20 -l walltime=336:00:00 -l cput=9999:00:00' # Submit a big job in current directory - but don't add the current environment
alias medjob='qsub -q yosef3 -d $(pwd) -l nodes=1:ppn=12 -l walltime=96:00:00 -l cput=999:00:00 -V' # Submit a medium job in current directory
alias smalljob='qsub -q yosef3 -d $(pwd) -l nodes=1:ppn=8 -l walltime=96:00:00 -l cput=999:00:00 -V' # Submit a smaller job in current directory

alias clustersnake='snakemake -j 999 --cluster "qsub -q yosef3 -d $(pwd) -l nodes=1:ppn=20 -V -l walltime=96:00:00 -l cput=999:00:00"'
alias clustersnake-med='snakemake -j 999 --cluster "qsub -q yosef3 -d $(pwd) -l nodes=1:ppn=10 -V -l walltime=96:00:00 -l cput=999:00:00"'
alias clustersnake-gpu='snakemake -j 999 --cluster "qsub -q gpu -d $(pwd) -l nodes=1:ppn=20 -V -l walltime=96:00:00 -l cput=999:00:00"'

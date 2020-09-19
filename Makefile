.PHONY: all
all: deploy

.PHONY: deploy
deploy:
	@echo "Deploying dotfiles"
	# TODO: paramaterize rather than hard code values
	ssh dwhittington@192.168.8.2 rm -f /tmp/S.gpg-agent.ssh.djwhitt
	ssh -R /tmp/S.gpg-agent.ssh.djwhitt:/run/user/1000/gnupg/S.gpg-agent.ssh -o "StreamLocalBindUnlink=yes" dwhittington@192.168.8.2 bash -c 'echo && SSH_AUTH_SOCK=/tmp/S.gpg-agent.ssh.djwhitt mr up && rm -f /tmp/S.gpg-agent.ssh.djwhitt'
	ssh djwhitt@192.168.8.3 rm -f /tmp/S.gpg-agent.ssh.djwhitt
	ssh -R /tmp/S.gpg-agent.ssh.djwhitt:/run/user/1000/gnupg/S.gpg-agent.ssh -o "StreamLocalBindUnlink=yes" djwhitt@192.168.8.3 bash -c 'echo && SSH_AUTH_SOCK=/tmp/S.gpg-agent.ssh.djwhitt mr up && rm -f /tmp/S.gpg-agent.ssh.djwhitt'
	# TODO: fix double quoting
	vs-ssh dwhittington@viapair.lonocloud.viasat.io bash -c "'echo && mr up'"

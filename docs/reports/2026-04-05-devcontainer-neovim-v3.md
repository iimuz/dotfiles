```sh
#19 0.175 Downloading GitHub Copilot CLI from ********/github/copilot-cli/releases/latest/download/copilot-linux-x64.tar.gz...
#19 0.177 /tmp/copilotcli /tmp/dev-container-features/copilot-cli_7
#19 0.181 --2026-04-05 02:03:10--  ********/github/copilot-cli/releases/latest/download/copilot-linux-x64.tar.gz
#19 0.206 Resolving github.com (github.com)... 20.205.243.166
#19 0.210 Connecting to github.com (github.com)|20.205.243.166|:443... connected.
#19 0.214 HTTP request sent, awaiting response... 302 Found
#19 0.489 Location: ********/github/copilot-cli/releases/download/v1.0.18/copilot-linux-x64.tar.gz [following]
#19 0.489 --2026-04-05 02:03:10--  ********/github/copilot-cli/releases/download/v1.0.18/copilot-linux-x64.tar.gz
#19 0.489 Reusing existing connection to github.com:443.
#19 0.489 HTTP request sent, awaiting response... 302 Found
#19 0.777 Location: https://release-assets.githubusercontent.com/github-production-release-asset/585860664/8314bf6b-f118-49aa-a8d7-b6833186f708?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-04-05T02%3A56%3A21Z&rscd=attachment%3B+filename%3Dcopilot-linux-x64.tar.gz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-04-05T01%3A56%3A15Z&ske=2026-04-05T02%3A56%3A21Z&sks=b&skv=2018-11-09&sig=bszboh2mQIk95NuU78pnev7n1FxT6%2FPmLqeGZcmk%2Bms%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3NTM1NjM5MCwibmJmIjoxNzc1MzU0NTkwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.wcvUyZZ7BuP4iwdtVJ7eFgK_mSdRLChPtCX3LcKy3LM&response-content-disposition=attachment%3B%20filename%3Dcopilot-linux-x64.tar.gz&response-content-type=application%2Foctet-stream [following]
#19 0.777 --2026-04-05 02:03:10--  https://release-assets.githubusercontent.com/github-production-release-asset/585860664/8314bf6b-f118-49aa-a8d7-b6833186f708?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-04-05T02%3A56%3A21Z&rscd=attachment%3B+filename%3Dcopilot-linux-x64.tar.gz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-04-05T01%3A56%3A15Z&ske=2026-04-05T02%3A56%3A21Z&sks=b&skv=2018-11-09&sig=bszboh2mQIk95NuU78pnev7n1FxT6%2FPmLqeGZcmk%2Bms%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3NTM1NjM5MCwibmJmIjoxNzc1MzU0NTkwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.wcvUyZZ7BuP4iwdtVJ7eFgK_mSdRLChPtCX3LcKy3LM&response-content-disposition=attachment%3B%20filename%3Dcopilot-linux-x64.tar.gz&response-content-type=application%2Foctet-stream
#19 0.777 Resolving release-assets.githubusercontent.com (release-assets.githubusercontent.com)... 185.199.109.133, 185.199.110.133, 185.199.111.133, ...
#19 0.788 Connecting to release-assets.githubusercontent.com (release-assets.githubusercontent.com)|185.199.109.133|:443... connected.
#19 0.795 HTTP request sent, awaiting response... 200 OK
#19 0.799 Length: 62178204 (59M) [application/octet-stream]
#19 0.800 Saving to: 'copilot-linux-x64.tar.gz'
#19 0.808
#19 0.808      0K ........ ........ ........ ........ 53% 97.8M 0s
#19 1.130  32768K ........ ........ ........ ...     100%  199M=0.5s
#19 1.264
#19 1.264 2026-04-05 02:03:11 (128 MB/s) - 'copilot-linux-x64.tar.gz' saved [62178204/62178204]
#19 1.264
#19 2.156 /tmp/dev-container-features/copilot-cli_7
#19 DONE 3.7s

#20 [dev_containers_target_stage 13/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=github-cli_8,target=/tmp/build-features-src/github-cli_8     cp -ar /tmp/build-features-src/github-cli_8 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/github-cli_8  && cd /tmp/dev-container-features/github-cli_8  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/github-cli_8
#20 0.160 ===========================================================================
#20 0.160 Feature       : GitHub CLI
#20 0.160 Description   : Installs the GitHub CLI. Auto-detects latest version and installs needed dependencies.
#20 0.160 Id            : ghcr.io/devcontainers/features/github-cli
#20 0.160 Version       : 1.1.0
#20 0.160 Documentation : ********/devcontainers/features/tree/main/src/github-cli
#20 0.160 Options       :
#20 0.160     VERSION="latest"
#20 0.160     INSTALLDIRECTLYFROMGITHUBRELEASE="********"
#20 0.160     EXTENSIONS="dlvhdr/gh-dash"
#20 0.160 ===========================================================================
#20 0.173 Downloading github CLI...
#20 0.716 CLI_VERSION=2.89.0
#20 0.718 /tmp/ghcli /tmp/dev-container-features/github-cli_8
#20 1.304
#20 1.304      0K ........ .....                     100% 45.2M=0.3s
#20 1.600
#20 1.633 Selecting previously unselected package gh.
#20 1.647 (Reading database ... 22432 files and directories currently installed.)
#20 1.648 Preparing to unpack .../gh_2.89.0_linux_amd64.deb ...
#20 1.651 Unpacking gh (2.89.0) ...
#20 1.870 Setting up gh (2.89.0) ...
#20 1.877 Processing triggers for man-db (2.12.0-4build2) ...
#20 1.992 /tmp/dev-container-features/github-cli_8
#20 2.058 Installing GitHub CLI extensions: dlvhdr/gh-dash
#20 2.066 Cloning into '/home/vscode/.local/share/gh/extensions/gh-dash'...
#20 DONE 6.0s

#21 [dev_containers_target_stage 14/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=sshd_9,target=/tmp/build-features-src/sshd_9     cp -ar /tmp/build-features-src/sshd_9 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/sshd_9  && cd /tmp/dev-container-features/sshd_9  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/sshd_9
#21 0.305 ===========================================================================
#21 0.305 Feature       : SSH server
#21 0.305 Description   : Adds a SSH server into a container so that you can use an external terminal, sftp, or SSHFS to interact with it.
#21 0.305 Id            : ghcr.io/devcontainers/features/sshd
#21 0.305 Version       : 1.1.0
#21 0.305 Documentation : ********/devcontainers/features/tree/main/src/sshd
#21 0.305 Options       :
#21 0.305     VERSION="latest"
#21 0.305     GATEWAYPORTS="no"
#21 0.305 ===========================================================================
#21 0.321 find: '/var/lib/apt/lists/*': No such file or directory
#21 0.321 Running apt-get update...
#21 0.843 Get:1 http://archive.ubuntu.com/ubuntu noble InRelease [256 kB]
#21 0.953 Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
#21 1.807 Get:3 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Packages [34.8 kB]
#21 2.026 Get:4 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Packages [3499 kB]
#21 2.153 Get:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
#21 2.476 Get:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
#21 2.800 Get:7 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages [1808 kB]
#21 2.919 Get:8 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [1504 kB]
#21 3.011 Get:9 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [1985 kB]
#21 3.555 Get:10 http://archive.ubuntu.com/ubuntu noble/restricted amd64 Packages [117 kB]
#21 3.573 Get:11 http://archive.ubuntu.com/ubuntu noble/multiverse amd64 Packages [331 kB]
#21 3.620 Get:12 http://archive.ubuntu.com/ubuntu noble/universe amd64 Packages [19.3 MB]
#21 4.779 Get:13 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Packages [38.1 kB]
#21 4.780 Get:14 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [2369 kB]
#21 4.918 Get:15 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Packages [3669 kB]
#21 5.114 Get:16 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [2152 kB]
#21 5.226 Get:17 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Packages [36.1 kB]
#21 5.228 Get:18 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Packages [49.5 kB]
#21 5.231 Get:19 http://archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 Packages [695 B]
#21 5.725 Fetched 37.5 MB in 5s (6993 kB/s)
#21 5.725 Reading package lists...
#21 6.564 Reading package lists...
#21 7.400 Building dependency tree...
#21 7.592 Reading state information...
#21 7.761 openssh-client is already the newest version (1:9.6p1-3ubuntu13.15).
#21 7.761 lsof is already the newest version (4.95.0-1build3).
#21 7.761 The following additional packages will be installed:
#21 7.762   libwrap0 openssh-sftp-server ucf
#21 7.763 Suggested packages:
#21 7.763   molly-guard monkeysphere ssh-askpass ufw
#21 7.763 Recommended packages:
#21 7.763   default-logind | logind | libpam-systemd ncurses-term xauth ssh-import-id
#21 7.808 The following NEW packages will be installed:
#21 7.808   libwrap0 openssh-server openssh-sftp-server ucf
#21 8.652 0 upgraded, 4 newly installed, 0 to remove and 0 not upgraded.
#21 8.652 Need to get 651 kB of archives.
#21 8.652 After this operation, 2575 kB of additional disk space will be used.
#21 8.652 Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 openssh-sftp-server amd64 1:9.6p1-3ubuntu13.15 [37.3 kB]
#21 9.103 Get:2 http://archive.ubuntu.com/ubuntu noble/main amd64 ucf all 3.0043+nmu1 [56.5 kB]
#21 9.307 Get:3 http://archive.ubuntu.com/ubuntu noble/main amd64 libwrap0 amd64 7.6.q-33 [47.9 kB]
#21 9.464 Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 openssh-server amd64 1:9.6p1-3ubuntu13.15 [510 kB]
#21 10.85 Preconfiguring packages ...
#21 10.91 Fetched 651 kB in 2s (315 kB/s)
#21 10.93 Selecting previously unselected package openssh-sftp-server.
(Reading database ... 22651 files and directories currently installed.)
#21 10.95 Preparing to unpack .../openssh-sftp-server_1%3a9.6p1-3ubuntu13.15_amd64.deb ...
#21 10.95 Unpacking openssh-sftp-server (1:9.6p1-3ubuntu13.15) ...
#21 10.99 Selecting previously unselected package ucf.
#21 10.99 Preparing to unpack .../ucf_3.0043+nmu1_all.deb ...
#21 10.99 Moving old data out of the way
#21 10.99 Unpacking ucf (3.0043+nmu1) ...
#21 11.03 Selecting previously unselected package libwrap0:amd64.
#21 11.03 Preparing to unpack .../libwrap0_7.6.q-33_amd64.deb ...
#21 11.03 Unpacking libwrap0:amd64 (7.6.q-33) ...
#21 11.06 Selecting previously unselected package openssh-server.
#21 11.06 Preparing to unpack .../openssh-server_1%3a9.6p1-3ubuntu13.15_amd64.deb ...
#21 11.07 Unpacking openssh-server (1:9.6p1-3ubuntu13.15) ...
#21 11.13 Setting up openssh-sftp-server (1:9.6p1-3ubuntu13.15) ...
#21 11.14 Setting up libwrap0:amd64 (7.6.q-33) ...
#21 11.15 Setting up ucf (3.0043+nmu1) ...
#21 11.22 Setting up openssh-server (1:9.6p1-3ubuntu13.15) ...
#21 11.34
#21 11.34 Creating config file /etc/ssh/sshd_config with new version
#21 11.37 Creating SSH2 RSA key; this may take some time ...
#21 12.21 3072 SHA256:gEEgVCOB48Icg4vfXV5FvnLE0zTEyMLROdpyZ9GlxYw root@buildkitsandbox (RSA)
#21 12.22 Creating SSH2 ECDSA key; this may take some time ...
#21 12.22 256 SHA256:NBN08pC/wa4ilb3m4xyQFVyK5OxbjOD0FDWyIlzSJH4 root@buildkitsandbox (ECDSA)
#21 12.23 Creating SSH2 ED25519 key; this may take some time ...
#21 12.23 256 SHA256:/j6nMrjRrugnuPdyks3J0rbWWdyOycINGNF4mTSeOBk root@buildkitsandbox (ED25519)
#21 12.44 invoke-rc.d: could not determine current runlevel
#21 12.44 invoke-rc.d: policy-rc.d denied execution of start.
#21 12.64 Processing triggers for man-db (2.12.0-4build2) ...
#21 12.75 Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
#21 12.79 adding 'ssh' group, as it does not already exist.
#21 12.83 Done!
#21 12.83
#21 12.83 - Port: 2222
#21 12.83 - User: vscode
#21 12.85
#21 12.85 Forward port 2222 to your local machine and run:
#21 12.85
#21 12.85   ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null vscode@localhost
#21 12.85
#21 DONE 12.9s

#22 [dev_containers_target_stage 15/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=jq-likes_10,target=/tmp/build-features-src/jq-likes_10     cp -ar /tmp/build-features-src/jq-likes_10 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/jq-likes_10  && cd /tmp/dev-container-features/jq-likes_10  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/jq-likes_10
#22 0.279 ===========================================================================
#22 0.279 Feature       : jq, yq, gojq, xq, jaq
#22 0.279 Description   : Installs jq and jq like command line tools (yq, gojq, xq, jaq).
#22 0.279 Id            : ghcr.io/eitsupi/devcontainer-features/jq-likes
#22 0.279 Version       : 2.1.1
#22 0.279 Documentation : ********/eitsupi/devcontainer-features/tree/main/src/jq-likes
#22 0.279 Options       :
#22 0.279     JQVERSION="latest"
#22 0.279     YQVERSION="4"
#22 0.279     GOJQVERSION="none"
#22 0.279     XQVERSION="none"
#22 0.279     JAQVERSION="none"
#22 0.279     ALLOWJQRCVERSION="false"
#22 0.279 ===========================================================================
#22 0.833 JQ_VERSION=1.8.1
#22 1.467 YQ_VERSION=4.52.5
#22 1.473 Downloading jq 1.8.1...
#22 1.867 Downloading yq 4.52.5...
#22 2.555 /tmp/yq /tmp/dev-container-features/jq-likes_10
#22 2.564 /tmp/dev-container-features/jq-likes_10
#22 2.570 Installing bash completion...
#22 2.582 Installing zsh completion...
#22 2.642 Done!
#22 DONE 2.8s

#23 [dev_containers_target_stage 16/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=neovim_11,target=/tmp/build-features-src/neovim_11     cp -ar /tmp/build-features-src/neovim_11 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/neovim_11  && cd /tmp/dev-container-features/neovim_11  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/neovim_11
#23 0.278 ===========================================================================
#23 0.278 Feature       : Neovim
#23 0.278 Description   : Installs Neovim Editor. See neovim.io
#23 0.278 Id            : ghcr.io/stu-bell/devcontainer-features/neovim
#23 0.278 Version       : 0.1.2
#23 0.278 Documentation :
#23 0.278 Options       :
#23 0.278     CONFIG_GIT_URL=""
#23 0.278     CONFIG_LOCATION="/config"
#23 0.278 ===========================================================================
#23 0.285 Installing neovim via appimage: https://neovim.io/doc/install/#appimage-universal-linux-package
#23 0.292   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#23 0.292                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 10.8M  100 10.8M    0     0  9006k      0  0:00:01  0:00:01 --:--:--  419M
#23 1.810 Neovim installed successfully:
#23 1.815 NVIM v0.12.0
#23 1.815 Build type: Release
#23 1.815 LuaJIT 2.1.1774638290
#23 1.815 Run "nvim -V1 -v" for more info
#23 DONE 2.3s

#24 preparing layers for inline cache
#24 DONE 10.6s

#25 exporting to image
#25 exporting layers done
#25 writing image sha256:3c12c2dde3a90eb890955d31476d946af102bd2246bab7146eccdb63ce1219c2 done
#25 naming to docker.io/library/vsc-dotfiles-a27ca6b2102aafb81f317f594f8e65e53031b8ec9c85f8682cc9c6ac78502164-features done
#25 DONE 0.0s
[229094 ms] Stop: Run: docker buildx build --load --build-arg BUILDKIT_INLINE_CACHE=1 --build-context dev_containers_feature_content_source=/tmp/devcontainercli-root/container-features/0.83.3-1775354386648 --build-arg _DEV_CONTAINERS_BASE_IMAGE=mcr.microsoft.com/devcontainers/base:ubuntu-24.04 --build-arg _DEV_CONTAINERS_IMAGE_USER=root --build-arg _DEV_CONTAINERS_FEATURE_CONTENT_SOURCE=dev_container_feature_content_temp --target dev_containers_target_stage -f /tmp/devcontainercli-root/container-features/0.83.3-1775354386648/Dockerfile.extended -t vsc-dotfiles-a27ca6b2102aafb81f317f594f8e65e53031b8ec9c85f8682cc9c6ac78502164-features /var/lib/docker/codespacemount/.persistedshare/empty-folder
[242219 ms] Start: Run: docker run --sig-proxy=false -a STDOUT -a STDERR --mount type=bind,src=/var/lib/docker/codespacemount/workspace,dst=/workspaces --mount source=/root/.codespaces/shared,target=/workspaces/.codespaces/shared,type=bind --mount source=/var/lib/docker/codespacemount/.persistedshare,target=/workspaces/.codespaces/.persistedshare,type=bind --mount source=/.codespaces/agent/mount,target=/.codespaces/bin,type=bind --mount source=/mnt/containerTmp,target=/tmp,type=bind --mount type=bind,src=/.codespaces/agent/mount/cache,dst=/vscode -l Type=codespaces -e CODESPACES=******** -e ContainerVersion=13 -e RepositoryName=dotfiles --label ContainerVersion=13 --hostname codespaces-e7e5e2 --add-host codespaces-e7e5e2:127.0.0.1 --cap-add sys_nice --network host --entrypoint /bin/sh vsc-dotfiles-a27ca6b2102aafb81f317f594f8e65e53031b8ec9c85f8682cc9c6ac78502164-features -c echo Container started
Container started
Outcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Running blocking commands...
$ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/dotfiles --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --user-data-folder /var/lib/docker/codespacemount/.persistedshare --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --omit-config-remote-env-from-metadata --skip-non-blocking-commands --expect-existing-container --config "/var/lib/docker/codespacemount/workspace/dotfiles/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json
[200 ms] @devcontainers/cli 0.83.3. Node.js v18.20.8. linux 6.8.0-1044-azure x64.
Outcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Configuring codespace...
Running commands...
$ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/dotfiles --expect-existing-container --skip-post-attach --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --config "/var/lib/docker/codespacemount/workspace/dotfiles/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json
[197 ms] @devcontainers/cli 0.83.3. Node.js v18.20.8. linux 6.8.0-1044-azure x64.
Running the postCreateCommand from devcontainer.json...

bash .devcontainer/post-install.sh
mise trusted /workspaces/dotfiles
[2026-04-05 02:03:51] [INFO] Setting up dotfiles...
mise WARN  No untrusted config files found.
set load setting in /home/vscode/.zshrc: /workspaces/dotfiles/.config/rc-settings.sh
symlink /workspaces/dotfiles/.config/gh-dash/config.yml to /home/vscode/.config/gh-dash/config.yml
symlink /workspaces/dotfiles/.gitconfig to /home/vscode/.gitconfig
symlink /workspaces/dotfiles/.config/git/ignore to /home/vscode/.config/git/ignore
symlink /workspaces/dotfiles/.config/git/credential-gh-helper to /home/vscode/.local/bin/credential-gh-helper
symlink /workspaces/dotfiles/.config/copilot/agents to /home/vscode/.copilot/agents
symlink /workspaces/dotfiles/.config/copilot/skills to /home/vscode/.copilot/skills
symlink /workspaces/dotfiles/.config/copilot/mcp-config.json to /home/vscode/.copilot/mcp-config.json
symlink /workspaces/dotfiles/.config/lazygit/config.yml to /home/vscode/.config/lazygit/config.yml
symlink /workspaces/dotfiles/.config/mise/config-codespaces.toml to /home/vscode/.config/mise/config.toml
symlink /workspaces/dotfiles/.config/nvim to /home/vscode/.config/nvim
symlink /workspaces/dotfiles/.tmux.conf to /home/vscode/.tmux.conf
symlink /workspaces/dotfiles/.config/vifm/vifmrc to /home/vscode/.config/vifm/vifmrc
mise trusted /home/vscode
mise WARN  npm may be required but was not found.

To use npm packages with mise, you need to install Node.js first:
mise use node@latest

Note: npm is required for querying package information, even when using bun for installation.
mise WARN  npm may be required but was not found.

To use npm packages with mise, you need to install Node.js first:
mise use node@latest

Note: npm is required for querying package information, even when using bun for installation.
mise WARN  npm may be required but was not found.

To use npm packages with mise, you need to install Node.js first:
mise use node@latest

Note: npm is required for querying package information, even when using bun for installation.
mise hint use multiple versions simultaneously with mise use python@3.12 python@3.11
mise Downloading https://www.lua.org/ftp/lua-5.1.5.tar.gz
mise WARN  npm may be required but was not found.

To use npm packages with mise, you need to install Node.js first:
mise use node@latest

Note: npm is required for querying package information, even when using bun for installation.
mise WARN  npm may be required but was not found.

To use npm packages with mise, you need to install Node.js first:
mise use node@latest

Note: npm is required for querying package information, even when using bun for installation.
mise WARN  npm may be required but was not found.

To use npm packages with mise, you need to install Node.js first:
mise use node@latest

Note: npm is required for querying package information, even when using bun for installation.
mise WARN  Failed to resolve tool version list for npm:neovim: [~/.config/mise/config.toml] npm:neovim@5.4.0: No such file or directory (os error 2)
mise WARN  Failed to resolve tool version list for npm:@aikidosec/safe-chain: [~/.config/mise/config.toml] npm:@aikidosec/safe-chain@1.4.7: No such file or directory (os error 2)
mise WARN  Failed to resolve tool version list for npm:mcp-remote: [~/.config/mise/config.toml] npm:mcp-remote@0.1.38: No such file or directory (os error 2)
info: downloading installer
mise hint installing precompiled python from astral-sh/python-build-standalone
if you experience issues with this python (e.g.: running poetry), switch to python-build by running mise settings python.compile=1
warn: It looks like you have an existing rustup settings file at:
warn: /home/vscode/.rustup/settings.toml
warn: Rustup will install the default toolchain as specified in the settings file,
warn: instead of the one inferred from the default host triple.
info: profile set to default
info: default host triple is x86_64-unknown-linux-gnu
info: skipping toolchain installation
info: syncing channel updates for 1.94.1-x86_64-unknown-linux-gnu
info: latest update on 2026-03-26 for version 1.94.1 (e408947bf 2026-03-25)
info: downloading 6 components
gpg: Signature made Tue Feb 24 15:33:35 2026 UTC
gpg:                using RSA key 108F52B48DB57BB0CC439B2997B01419BD92F80A
gpg: Good signature from "Ruy Adorno <ruyadorno@hotmail.com>" [unknown]
mise Verifying "/home/vscode/.local/share/mise/downloads/lua-5.1.5/lua-5.1.5.tar.gz" checksum
mise Extracting "/home/vscode/.local/share/mise/downloads/lua-5.1.5/lua-5.1.5.tar.gz" to "/home/vscode/.local/share/mise/installs/lua/5.1.5"
mise 2026.4.3 by @jdx                                                     [1/17]
cargo-binstall@1.17.9               download cargo-binstall-x86_64-unknown-li… ◠
lua@5.1.5                           install                                    ◠
mise 2026.4.3 by @jdx                                                     [3/17]
cargo-binstall@1.17.9               download cargo-binstall-x86_64-unknown-li… ◝
mise 2026.4.3 by @jdx                                                     [3/17]
cargo-binstall@1.17.9               download cargo-binstall-x86_64-unknown-li… ◞
lua@5.1.5                           install                                    ◞
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◞
mise 2026.4.3 by @jdx                                                     [3/17]
cargo-binstall@1.17.9               download cargo-binstall-x86_64-unknown-li… ◟
lua@5.1.5                           install                                    ◟
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◟
mise 2026.4.3 by @jdx                                                     [3/17]
mise Cannot parse Rekor public key with id cf1199155bddd051268d1f16ac5c0c75c009f6fb5a63f4177f8e18d7051e3fa0: Pkcs8 spki error : Ecdsa-P256 from der bytes to public key failed: unknown/unsupported algorithm OID: 1.2.840.10045.2.1
mise 2026.4.3 by @jdx                                                     [3/17]
mise 2026.4.3 by @jdx                                                     [3/17]
mise 2026.4.3 by @jdx                                                     [3/17]
ldump.c: In function 'DumpString':
ldump.c:63:26: warning: the comparison will always evaluate as 'false' for the pointer operand in 's + 24' must not be NULL [-Waddress]
   63 |  if (s==NULL || getstr(s)==NULL)
      |                          ^~
mise 2026.4.3 by @jdx                                                     [3/17]
mise 2026.4.3 by @jdx                                                     [3/17]
mise 2026.4.3 by @jdx                                                     [3/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ◡
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise Cannot parse Rekor public key with id cf1199155bddd051268d1f16ac5c0c75c009f6fb5a63f4177f8e18d7051e3fa0: Pkcs8 spki error : Ecdsa-P256 from der bytes to public key failed: unknown/unsupported algorithm OID: 1.2.840.10045.2.1
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ◝
lua@5.1.5                           install                                    ◝
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◝
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       extract cpython-3.14.3+20260324-x86_64…    ◝
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ◝
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ◡
lua@5.1.5                           install                                    ◡
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◡
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       extract cpython-3.14.3+20260324-x86_64…    ◡
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [5/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ◝
lua@5.1.5                           install                                    ◝
mise 2026.4.3 by @jdx                                                     [5/17]
mise 2026.4.3 by @jdx                                                     [8/17]
mise 2026.4.3 by @jdx                                                     [8/17]
mise 2026.4.3 by @jdx                                                    [11/17]
mise 2026.4.3 by @jdx                                                    [11/17]
Resolved 3 packages in 270ms
Prepared 3 packages in 100ms
Installed 3 packages in 69ms
 + greenlet==3.3.2
 + msgpack==1.1.2
 + pynvim==0.6.0
Installed 1 executable: pynvim-python
mise 2026.4.3 by @jdx                                                    [11/17]
Resolved 42 packages in 706ms
Downloading pygments (1.2MiB)
Downloading cryptography (4.3MiB)
Downloading pydantic-core (2.0MiB)
Resolved 69 packages in 989ms
mise 2026.4.3 by @jdx                                                    [11/17]
Downloading sympy (6.0MiB)
Downloading youtube-transcript-api (2.1MiB)
Downloading onnxruntime (16.4MiB)
Downloading speechrecognition (31.3MiB)
Downloading cryptography (4.3MiB)
Downloading pandas (10.4MiB)
Downloading pillow (6.8MiB)
Downloading pypdfium2 (3.5MiB)
Downloading lxml (5.0MiB)
Downloading magika (14.7MiB)
Downloading pdfminer-six (6.3MiB)
Downloading numpy (15.9MiB)
Downloading pydantic-core (2.0MiB)
make[2]: Leaving directory '/home/vscode/.local/share/mise/installs/lua/5.1.5/src'
make[1]: Leaving directory '/home/vscode/.local/share/mise/installs/lua/5.1.5/src'
 Downloaded pydantic-core
make install INSTALL_TOP=..
mise 2026.4.3 by @jdx                                                    [11/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
mise 2026.4.3 by @jdx                                                    [11/17]
mise 2026.4.3 by @jdx                                                    [11/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◡
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
 Downloaded cryptography
 Downloaded pygments
Prepared 42 packages in 1.90s
Installed 42 packages in 80ms
 + annotated-doc==0.0.4
 + annotated-types==0.7.0
 + anyio==4.13.0
 + attrs==26.1.0
 + awslabs-aws-documentation-mcp-server==1.1.20
 + beautifulsoup4==4.14.3
 + certifi==2026.2.25
 + cffi==2.0.0
 + click==8.3.2
 + cryptography==46.0.6
 + h11==0.16.0
 + httpcore==1.0.9
 + httpx==0.28.1
 + httpx-sse==0.4.3
 + idna==3.11
 + jsonschema==4.26.0
 + jsonschema-specifications==2025.9.1
 + loguru==0.7.3
 + markdown-it-py==4.0.0
 + markdownify==1.2.2
 + mcp==1.27.0
 + mdurl==0.1.2
 + pycparser==3.0
 + pydantic==2.12.5
 + pydantic-core==2.41.5
 + pydantic-settings==2.13.1
 + pygments==2.20.0
 + pyjwt==2.12.1
 + python-dotenv==1.2.2
 + python-multipart==0.0.22
 + referencing==0.37.0
 + rich==14.3.3
 + rpds-py==0.30.0
 + shellingham==1.5.4
 + six==1.17.0
 + soupsieve==2.8.3
 + sse-starlette==3.3.4
 + starlette==1.0.0
 + typer==0.24.1
 + typing-extensions==4.15.0
 + typing-inspection==0.4.2
 + uvicorn==0.43.0
Installed 1 executable: awslabs.aws-documentation-mcp-server
 Downloaded youtube-transcript-api
 Downloaded pydantic-core
 Downloaded pypdfium2
 Downloaded pdfminer-six
 Downloaded cryptography
 Downloaded pillow
 Downloaded lxml
 Downloaded magika
 Downloaded numpy
 Downloaded speechrecognition
 Downloaded onnxruntime
 Downloaded sympy
 Downloaded pandas
Prepared 68 packages in 3.84s
mise 2026.4.3 by @jdx                                                    [13/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◡
Installed 69 packages in 304ms
 + annotated-types==0.7.0
 + anyio==4.13.0
 + audioop-lts==0.2.2
 + azure-ai-documentintelligence==1.0.2
 + azure-core==1.39.0
 + azure-identity==1.25.3
Lua version detected: 5.1
 + beautifulsoup4==4.14.3
 + certifi==2026.2.25
 + cffi==2.0.0
 + charset-normalizer==3.4.7
 + click==8.3.2
 + cobble==0.1.4
 + cryptography==46.0.6
 + defusedxml==0.7.1
 + et-xmlfile==2.0.0
 + flatbuffers==25.12.19
 + h11==0.16.0
 + httpcore==1.0.9
 + httpx==0.28.1
 + httpx-sse==0.4.3
 + idna==3.11
 + isodate==0.7.2
 + lxml==6.0.2
 + magika==0.6.3
 + mammoth==1.11.0
 + markdownify==1.2.2
 + markitdown==0.1.5
 + markitdown-mcp==0.0.1a4
 + mcp==1.8.1
 + mpmath==1.3.0
 + msal==1.35.1
 + msal-extensions==1.3.1
 + numpy==2.4.4
 + olefile==0.47
 + onnxruntime==1.24.4
 + openpyxl==3.1.5
 + packaging==26.0
 + pandas==3.0.2
 + pdfminer-six==20251230
 + pdfplumber==0.11.9
 + pillow==12.2.0
 + protobuf==7.34.1
 + pycparser==3.0
 + pydantic==2.12.5
 + pydantic-core==2.41.5
 + pydantic-settings==2.13.1
 + pydub==0.25.1
 + pyjwt==2.12.1
 + pypdfium2==5.6.0
 + python-dateutil==2.9.0.post0
 + python-dotenv==1.2.2
 + python-multipart==0.0.22
 + python-pptx==1.0.2
 + requests==2.33.1
 + six==1.17.0
 + soupsieve==2.8.3
 + speechrecognition==3.15.2
 + sse-starlette==3.3.4
 + standard-aifc==3.13.0
 + standard-chunk==3.13.0
 + starlette==1.0.0
 + sympy==1.14.0
 + typing-extensions==4.15.0
 + typing-inspection==0.4.2
 + urllib3==2.6.3
 + uvicorn==0.43.0
 + xlrd==2.0.2
 + xlsxwriter==3.2.9
 + youtube-transcript-api==1.0.3
Lua interpreter found: /home/vscode/.local/share/mise/installs/lua/5.1.5/bin/lua
Installed 1 executable: markitdown-mcp
lua.h found: /home/vscode/.local/share/mise/installs/lua/5.1.5/include/lua.h
unzip found in PATH: /usr/bin
mise 2026.4.3 by @jdx                                                    [13/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◜
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◜
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
uv@0.11.3                           extract uv-x86_64-unknown-linux-musl.tar.… ✔
npm:mcp-remote@0.1.38               Done in 20.9s using pnpm v10.33.0          ✔
npm:@aikidosec/safe-chain@1.4.7     Done in 20.3s using pnpm v10.33.0          ✔
npm:neovim@5.4.0                    Done in 13.4s using pnpm v10.33.0          ✔
pipx:awslabs.aws-documentation-mcp-server@1.1.20 uv tool install awslabs.aws-… ✔
pipx:pynvim@0.6.0                   uv tool install pynvim==0.6.0              ✔
pipx:markitdown-mcp@0.0.1a4         uv tool install markitdown-mcp==0.0.1a4    ✔

Done configuring.

LuaRocks will be installed at......: /home/vscode/.local/share/mise/installs/lua/5.1.5/luarocks
LuaRocks will install rocks at.....: /home/vscode/.local/share/mise/installs/lua/5.1.5/luarocks
LuaRocks configuration directory...: /home/vscode/.local/share/mise/installs/lua/5.1.5/luarocks/etc/luarocks
Using Lua from.....................: /home/vscode/.local/share/mise/installs/lua/5.1.5
Lua include directory..............: /home/vscode/.local/share/mise/installs/lua/5.1.5/include
mise 2026.4.3 by @jdx                                                    [14/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◜
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◜
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
uv@0.11.3                           extract uv-x86_64-unknown-linux-musl.tar.… ✔
npm:mcp-remote@0.1.38               Done in 20.9s using pnpm v10.33.0          ✔
npm:@aikidosec/safe-chain@1.4.7     Done in 20.3s using pnpm v10.33.0          ✔
mise 2026.4.3 by @jdx                                                    [14/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
mise 2026.4.3 by @jdx                                                    [14/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
info: default toolchain set to 1.94.1-x86_64-unknown-linux-gnu
info: checking for self-update (current version: 1.29.0)
    Updating crates.io index
 Downloading crates ...
  Downloaded tree-sitter-cli v0.26.8
  Installing tree-sitter-cli v0.26.8
    Updating crates.io index
    Updating crates.io index
 Downloading crates ...
  Downloaded itoa v1.0.17
  Downloaded libloading v0.8.9
  Downloaded crc32fast v1.5.0
  Downloaded find-msvc-tools v0.1.9
  Downloaded topological-sort v0.2.2
  Downloaded siphasher v1.0.2
  Downloaded zerofrom-derive v0.1.6
  Downloaded zerovec-derive v0.11.2
  Downloaded unicode-ident v1.0.24
  Downloaded zmij v1.0.21
  Downloaded zerofrom v0.1.6
  Downloaded smallbitvec v2.6.0
  Downloaded webbrowser v1.1.0
  Downloaded zerocopy v0.8.39
  Downloaded unicode-width v0.2.2
  Downloaded indexmap v2.13.0
  Downloaded unicode-segmentation v1.12.0
  Downloaded zerovec v0.11.5
  Downloaded tree-sitter-generate v0.26.8
  Downloaded toml_edit v0.23.10+spec-1.0.0
  Downloaded serde_derive v1.0.228
  Downloaded zerotrie v0.2.3
  Downloaded libc v0.2.180
  Downloaded rquickjs-sys v0.10.0
  Downloaded icu_collections v2.1.1
  Downloaded syn v2.0.117
  Downloaded url v2.5.8
  Downloaded rustix v1.1.3
  Downloaded wasmparser v0.243.0
  Downloaded hashbrown v0.15.5
  Downloaded thread_local v1.1.9
  Downloaded rustix v0.38.44
  Downloaded icu_locale_core v2.1.1
  Downloaded hashbrown v0.16.1
  Downloaded quote v1.0.44
  Downloaded tree-sitter v0.26.8
  Downloaded phf_generator v0.13.1
  Downloaded is_terminal_polyfill v1.70.2
  Downloaded heck v0.5.0
  Downloaded regex-syntax v0.8.10
  Downloaded rand_core v0.6.4
  Downloaded regex-automata v0.4.14
  Downloaded icu_normalizer_data v2.1.1
  Downloaded minimal-lexical v0.2.1
  Downloaded phf_shared v0.13.1
  Downloaded percent-encoding v2.3.2
  Downloaded idna_adapter v1.2.1
  Downloaded icu_properties_data v2.1.2
  Downloaded glob v0.3.3
  Downloaded winnow v0.7.14
  Downloaded tree-sitter-loader v0.26.8
  Downloaded linux-raw-sys v0.4.15
  Downloaded toml_parser v1.0.9+spec-1.1.0
  Downloaded tinystr v0.8.2
  Downloaded synstructure v0.13.2
  Downloaded rand v0.8.5
  Downloaded phf v0.13.1
  Downloaded pathdiff v0.2.3
  Downloaded once_cell v1.21.3
  Downloaded icu_provider v2.1.1
  Downloaded icu_properties v2.1.2
  Downloaded icu_normalizer v2.1.1
  Downloaded getrandom v0.4.1
  Downloaded getrandom v0.2.17
  Downloaded fs4 v0.12.0
  Downloaded form_urlencoded v1.2.2
  Downloaded foldhash v0.2.0
  Downloaded prettyplease v0.2.37
  Downloaded fnv v1.0.7
  Downloaded fastrand v2.3.0
  Downloaded dialoguer v0.11.0
  Downloaded colorchoice v1.0.4
  Downloaded ansi_colours v1.2.3
  Downloaded allocator-api2 v0.2.21
  Downloaded yoke v0.8.1
  Downloaded utf8parse v0.2.2
  Downloaded utf8-width v0.1.8
  Downloaded tree-sitter-tags v0.26.8
  Downloaded tree-sitter-highlight v0.26.8
  Downloaded thiserror-impl v1.0.69
  Downloaded thiserror v2.0.18
  Downloaded thiserror v1.0.69
  Downloaded ref-cast-impl v1.0.25
  Downloaded ref-cast v1.0.25
  Downloaded proc-macro2 v1.0.106
  Downloaded potential_utf v0.1.4
  Downloaded log v0.4.29
  Downloaded litemap v0.8.1
  Downloaded libloading v0.9.0
  Downloaded ident_case v1.0.1
  Downloaded errno v0.3.14
  Downloaded either v1.15.0
  Downloaded ctrlc v3.5.2
  Downloaded clang-sys v1.8.1
  Downloaded cexpr v0.6.0
  Downloaded bytemuck v1.25.0
  Downloaded tree-sitter-language v0.1.7
  Downloaded tree-sitter-config v0.26.8
  Downloaded toml_datetime v0.7.5+spec-1.1.0
  Downloaded tiny_http v0.12.0
  Downloaded thiserror-impl v2.0.18
  Downloaded tempfile v3.25.0
  Downloaded streaming-iterator v0.1.9
  Downloaded stable_deref_trait v1.2.1
  Downloaded serde_json v1.0.149
  Downloaded regex v1.12.3
  Downloaded rand_chacha v0.3.1
  Downloaded proc-macro-crate v3.4.0
  Downloaded ppv-lite86 v0.2.21
  Downloaded nom v7.1.3
  Downloaded nix v0.31.1
  Downloaded memchr v2.8.0
  Downloaded itertools v0.13.0
  Downloaded idna v1.1.0
  Downloaded fuzzy-matcher v0.3.7
  Downloaded console v0.15.11
  Downloaded clap_complete v4.5.66
  Downloaded clap v4.5.60
  Downloaded cc v1.2.56
  Downloaded bstr v1.12.1
  Downloaded anstyle-parse v0.2.7
  Downloaded zeroize v1.8.2
  Downloaded yoke-derive v0.8.1
  Downloaded walkdir v2.5.0
  Downloaded strsim v0.11.1
  Downloaded smallvec v1.15.1
  Downloaded similar v2.7.0
  Downloaded shlex v1.3.0
  Downloaded serde_derive_internals v0.29.1
  Downloaded serde_core v1.0.228
  Downloaded serde v1.0.228
  Downloaded semver v1.0.27
  Downloaded schemars v1.2.1
  Downloaded rquickjs-macro v0.10.0
  Downloaded rquickjs-core v0.10.0
  Downloaded rgb v0.8.52
  Downloaded relative-path v2.0.1
  Downloaded httpdate v1.0.3
  Downloaded html-escape v0.2.13
  Downloaded dunce v1.0.5
  Downloaded ctor v0.2.9
  Downloaded convert_case v0.8.0
  Downloaded clap_builder v4.5.60
  Downloaded anstream v0.6.21
  Downloaded linux-raw-sys v0.11.0
  Downloaded writeable v0.6.2
  Downloaded utf8_iter v1.0.4
  Downloaded schemars_derive v1.2.1
  Downloaded same-file v1.0.6
  Downloaded rustversion v1.0.22
  Downloaded rustc-hash v2.1.1
  Downloaded rquickjs v0.10.0
  Downloaded foldhash v0.1.5
  Downloaded dyn-clone v1.0.20
  Downloaded clap_lex v1.0.0
  Downloaded chunked_transfer v1.5.0
  Downloaded cfg-if v1.0.4
  Downloaded bitflags v2.11.0
  Downloaded shell-words v1.1.1
  Downloaded etcetera v0.11.0
  Downloaded bindgen v0.72.1
  Downloaded anyhow v1.0.102
  Downloaded anstyle-query v1.1.5
  Downloaded anstyle v1.0.13
  Downloaded displaydoc v0.2.5
  Downloaded clap_derive v4.5.55
  Downloaded clap_complete_nushell v4.5.10
  Downloaded equivalent v1.0.2
  Downloaded cfg_aliases v0.2.1
  Downloaded ascii v1.1.0
  Downloaded aho-corasick v1.1.4
  Downloaded indoc v2.0.7
   Compiling proc-macro2 v1.0.106
   Compiling unicode-ident v1.0.24
   Compiling quote v1.0.44
   Compiling memchr v2.8.0
   Compiling shlex v1.3.0
   Compiling find-msvc-tools v0.1.9
   Compiling foldhash v0.2.0
   Compiling equivalent v1.0.2
   Compiling cc v1.2.56
   Compiling allocator-api2 v0.2.21
   Compiling zmij v1.0.21
   Compiling cfg-if v1.0.4
   Compiling glob v0.3.3
   Compiling hashbrown v0.16.1
   Compiling libc v0.2.180
   Compiling clang-sys v1.8.1
   Compiling stable_deref_trait v1.2.1
   Compiling syn v2.0.117
   Compiling prettyplease v0.2.37
   Compiling regex-syntax v0.8.10
   Compiling indexmap v2.13.0
   Compiling minimal-lexical v0.2.1
   Compiling nom v7.1.3
   Compiling libloading v0.8.9
   Compiling either v1.15.0
   Compiling serde_core v1.0.228
   Compiling bindgen v0.72.1
   Compiling regex-automata v0.4.14
   Compiling cexpr v0.6.0
   Compiling regex v1.12.3
   Compiling itertools v0.13.0
   Compiling bitflags v2.11.0
   Compiling synstructure v0.13.2
   Compiling rustc-hash v2.1.1
   Compiling log v0.4.29
   Compiling zerofrom-derive v0.1.6
   Compiling yoke-derive v0.8.1
   Compiling zerovec-derive v0.11.2
   Compiling displaydoc v0.2.5
   Compiling zerofrom v0.1.6
   Compiling yoke v0.8.1
   Compiling serde_json v1.0.149
   Compiling zerovec v0.11.5
   Compiling itoa v1.0.17
   Compiling tree-sitter-language v0.1.7
   Compiling aho-corasick v1.1.4
   Compiling tinystr v0.8.2
   Compiling serde v1.0.228
   Compiling writeable v0.6.2
   Compiling litemap v0.8.1
   Compiling icu_locale_core v2.1.1
   Compiling tree-sitter v0.26.8
   Compiling rquickjs-sys v0.10.0
   Compiling potential_utf v0.1.4
   Compiling zerotrie v0.2.3
   Compiling serde_derive v1.0.228
   Compiling thiserror v2.0.18
   Compiling icu_properties_data v2.1.2
   Compiling icu_normalizer_data v2.1.1
   Compiling icu_provider v2.1.1
   Compiling icu_collections v2.1.1
   Compiling thiserror-impl v2.0.18
   Compiling winnow v0.7.14
   Compiling utf8parse v0.2.2
   Compiling anstyle-parse v0.2.7
   Compiling toml_parser v1.0.9+spec-1.1.0
   Compiling siphasher v1.0.2
   Compiling getrandom v0.4.1
   Compiling anstyle-query v1.1.5
   Compiling is_terminal_polyfill v1.70.2
   Compiling colorchoice v1.0.4
   Compiling anstyle v1.0.13
   Compiling toml_datetime v0.7.5+spec-1.1.0
   Compiling smallvec v1.15.1
   Compiling zerocopy v0.8.39
   Compiling rustix v1.1.3
   Compiling icu_normalizer v2.1.1
   Compiling phf_shared v0.13.1
   Compiling toml_edit v0.23.10+spec-1.0.0
   Compiling anstream v0.6.21
   Compiling icu_properties v2.1.2
   Compiling heck v0.5.0
   Compiling relative-path v2.0.1
   Compiling unicode-segmentation v1.12.0
   Compiling streaming-iterator v0.1.9
   Compiling cfg_aliases v0.2.1
   Compiling fastrand v2.3.0
   Compiling rustix v0.38.44
   Compiling linux-raw-sys v0.11.0
   Compiling once_cell v1.21.3
   Compiling clap_lex v1.0.0
   Compiling strsim v0.11.1
   Compiling clap_builder v4.5.60
   Compiling phf_generator v0.13.1
   Compiling nix v0.31.1
   Compiling convert_case v0.8.0
   Compiling clap_derive v4.5.55
   Compiling idna_adapter v1.2.1
   Compiling proc-macro-crate v3.4.0
   Compiling phf v0.13.1
   Compiling semver v1.0.27
   Compiling getrandom v0.2.17
   Compiling thiserror v1.0.69
   Compiling fnv v1.0.7
   Compiling linux-raw-sys v0.4.15
   Compiling utf8_iter v1.0.4
   Compiling ident_case v1.0.1
   Compiling percent-encoding v2.3.2
   Compiling ref-cast v1.0.25
   Compiling form_urlencoded v1.2.2
   Compiling tempfile v3.25.0
   Compiling ppv-lite86 v0.2.21
   Compiling idna v1.1.0
   Compiling rand_core v0.6.4
   Compiling clap v4.5.60
   Compiling thiserror-impl v1.0.69
   Compiling ref-cast-impl v1.0.25
   Compiling serde_derive_internals v0.29.1
   Compiling etcetera v0.11.0
   Compiling thread_local v1.1.9
   Compiling anyhow v1.0.102
   Compiling unicode-width v0.2.2
   Compiling crc32fast v1.5.0
   Compiling tree-sitter-loader v0.26.8
   Compiling foldhash v0.1.5
   Compiling wasmparser v0.243.0
   Compiling indoc v2.0.7
   Compiling bytemuck v1.25.0
   Compiling rquickjs-core v0.10.0
   Compiling rgb v0.8.52
   Compiling hashbrown v0.15.5
   Compiling console v0.15.11
   Compiling schemars_derive v1.2.1
   Compiling rquickjs-macro v0.10.0
   Compiling fuzzy-matcher v0.3.7
   Compiling clap_complete v4.5.66
   Compiling rand_chacha v0.3.1
   Compiling fs4 v0.12.0
   Compiling url v2.5.8
   Compiling tree-sitter-tags v0.26.8
   Compiling tree-sitter-highlight v0.26.8
   Compiling libloading v0.9.0
   Compiling pathdiff v0.2.3
   Compiling ascii v1.1.0
   Compiling topological-sort v0.2.2
   Compiling dyn-clone v1.0.20
   Compiling same-file v1.0.6
   Compiling dunce v1.0.5
   Compiling chunked_transfer v1.5.0
   Compiling tree-sitter-cli v0.26.8
   Compiling httpdate v1.0.3
   Compiling utf8-width v0.1.8
   Compiling zeroize v1.8.2
   Compiling smallbitvec v2.6.0
   Compiling shell-words v1.1.1
   Compiling dialoguer v0.11.0
   Compiling tiny_http v0.12.0
   Compiling html-escape v0.2.13
   Compiling walkdir v2.5.0
   Compiling schemars v1.2.1
   Compiling webbrowser v1.1.0
   Compiling rand v0.8.5
   Compiling clap_complete_nushell v4.5.10
   Compiling ctrlc v3.5.2
   Compiling ansi_colours v1.2.3
   Compiling tree-sitter-config v0.26.8
   Compiling bstr v1.12.1
   Compiling ctor v0.2.9
   Compiling similar v2.7.0
   Compiling rquickjs v0.10.0
   Compiling tree-sitter-generate v0.26.8
    Finished `release` profile [optimized] target(s) in 2m 19s
  Installing /home/vscode/.local/share/mise/installs/cargo-tree-sitter-cli/0.26.8/bin/tree-sitter
   Installed package `tree-sitter-cli v0.26.8` (executable `tree-sitter`)
warning: be sure to add `/home/vscode/.local/share/mise/installs/cargo-tree-sitter-cli/0.26.8/bin` to your PATH to be able to run the installed binaries
mise 2026.4.3 by @jdx                                                    [17/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ✔
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
rust@1.94.1                         rustc 1.94.1 (e408947bf 2026-03-25)        ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
uv@0.11.3                           extract uv-x86_64-unknown-linux-musl.tar.… ✔
npm:mcp-remote@0.1.38               Done in 20.9s using pnpm v10.33.0          ✔
npm:@aikidosec/safe-chain@1.4.7     Done in 20.3s using pnpm v10.33.0          ✔
npm:neovim@5.4.0                    Done in 13.4s using pnpm v10.33.0          ✔
pipx:awslabs.aws-documentation-mcp-server@1.1.20 uv tool install awslabs.aws-… ✔
pipx:pynvim@0.6.0                   uv tool install pynvim==0.6.0              ✔
pipx:markitdown-mcp@0.0.1a4         uv tool install markitdown-mcp==0.0.1a4    ✔
cargo:tree-sitter-cli@0.26.8         INFO Done in 143.224240951s               ✔
mise all tools are installed
[2026-04-05 02:07:17] [INFO] Setting up Neovim...
[2026-04-05 02:07:17] [INFO] Bootstrapping lazy.nvim...
Cloning into '/home/vscode/.local/share/nvim/lazy/lazy.nvim'...
remote: Enumerating objects: 8166, done.
remote: Counting objects: 100% (1103/1103), done.
remote: Compressing objects: 100% (71/71), done.
remote: Total 8166 (delta 1075), reused 1032 (delta 1032), pack-reused 7063 (from 2)
Receiving objects: 100% (8166/8166), 1.62 MiB | 8.43 MiB/s, done.
Resolving deltas: 100% (4425/4425), done.
warning: refs/tags/stable 332b4cbc8bf61589b6ff58ce42fca80173154669 is not a commit!
Note: switching to '85c7ff3711b730b4030d03144f6db6375044ae82'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

remote: Enumerating objects: 97, done.
remote: Counting objects: 100% (62/62), done.
remote: Compressing objects: 100% (62/62), done.
remote: Total 97 (delta 0), reused 0 (delta 0), pack-reused 35 (from 2)
Receiving objects: 100% (97/97), 258.69 KiB | 3.54 MiB/s, done.
Error in command line:
E492: Not an editor command: Lazy! syncError in command line:
E492: Not an editor command: MasonToolsInstallSyncError in command line:
E492: Not an editor command: TSUpdateSyncOutcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Installing dotfiles...
$ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/dotfiles --expect-existing-container --skip-post-attach --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --config "/var/lib/docker/codespacemount/workspace/dotfiles/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --dotfiles-repository https://github.com/iimuz/dotfiles --dotfiles-target-path /workspaces/.codespaces/.persistedshare/dotfiles --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json
[149 ms] @devcontainers/cli 0.83.3. Node.js v18.20.8. linux 6.8.0-1044-azure x64.
[439 ms] Start: Run in container: # Clone & install dotfiles
[443 ms] Cloning into '/workspaces/.codespaces/.persistedshare/dotfiles'...

[1267 ms] Setting current directory to /workspaces/.codespaces/.persistedshare/dotfiles

[1269 ms] Linking dotfiles: /workspaces/.codespaces/.persistedshare/dotfiles/.config /workspaces/.codespaces/.persistedshare/dotfiles/.devcontainer /workspaces/.codespaces/.persistedshare/dotfiles/.editorconfig /workspaces/.codespaces/.persistedshare/dotfiles/.gitconfig /workspaces/.codespaces/.persistedshare/dotfiles/.github /workspaces/.codespaces/.persistedshare/dotfiles/.gitignore /workspaces/.codespaces/.persistedshare/dotfiles/.inputrc /workspaces/.codespaces/.persistedshare/dotfiles/.markdownlint-cli2.yaml /workspaces/.codespaces/.persistedshare/dotfiles/.mise /workspaces/.codespaces/.persistedshare/dotfiles/.prettierrc.yml /workspaces/.codespaces/.persistedshare/dotfiles/.shellcheckrc /workspaces/.codespaces/.persistedshare/dotfiles/.tmux.conf

[1271 ms]
[1271 ms]
[1271 ms] Exit code 1
[832 ms] Stop: Run in container: # Clone & install dotfiles
Outcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Finished configuring codespace.
```

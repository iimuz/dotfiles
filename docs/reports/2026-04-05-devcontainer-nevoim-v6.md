```sh
#20 1.187
#20 1.187      0K ........ .....                     100%  348M=0.04s
#20 1.217
#20 1.252 Selecting previously unselected package gh.
#20 1.266 (Reading database ... 22432 files and directories currently installed.)
#20 1.267 Preparing to unpack .../gh_2.89.0_linux_amd64.deb ...
#20 1.269 Unpacking gh (2.89.0) ...
#20 1.482 Setting up gh (2.89.0) ...
#20 1.489 Processing triggers for man-db (2.12.0-4build2) ...
#20 1.613 /tmp/dev-container-features/github-cli_8
#20 1.676 Installing GitHub CLI extensions: dlvhdr/gh-dash
#20 1.685 Cloning into '/home/vscode/.local/share/gh/extensions/gh-dash'...
#20 DONE 5.7s

#21 [dev_containers_target_stage 14/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=sshd_9,target=/tmp/build-features-src/sshd_9     cp -ar /tmp/build-features-src/sshd_9 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/sshd_9  && cd /tmp/dev-container-features/sshd_9  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/sshd_9
#21 0.230 ===========================================================================
#21 0.230 Feature       : SSH server
#21 0.230 Description   : Adds a SSH server into a container so that you can use an external terminal, sftp, or SSHFS to interact with it.
#21 0.230 Id            : ghcr.io/devcontainers/features/sshd
#21 0.230 Version       : 1.1.0
#21 0.230 Documentation : ********/devcontainers/features/tree/main/src/sshd
#21 0.230 Options       :
#21 0.230     VERSION="latest"
#21 0.230     GATEWAYPORTS="no"
#21 0.230 ===========================================================================
#21 0.245 find: '/var/lib/apt/lists/*': No such file or directory
#21 0.246 Running apt-get update...
#21 0.632 Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
#21 0.993 Get:2 http://archive.ubuntu.com/ubuntu noble InRelease [256 kB]
#21 1.489 Get:3 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [1504 kB]
#21 2.346 Get:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
#21 2.371 Get:5 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [1985 kB]
#21 2.578 Get:6 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Packages [34.8 kB]
#21 2.580 Get:7 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Packages [3499 kB]
#21 2.679 Get:8 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
#21 3.011 Get:9 http://archive.ubuntu.com/ubuntu noble/universe amd64 Packages [19.3 MB]
#21 5.689 Get:10 http://archive.ubuntu.com/ubuntu noble/multiverse amd64 Packages [331 kB]
#21 5.704 Get:11 http://archive.ubuntu.com/ubuntu noble/restricted amd64 Packages [117 kB]
#21 5.711 Get:12 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages [1808 kB]
#21 5.856 Get:13 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [2369 kB]
#21 5.991 Get:14 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Packages [38.1 kB]
#21 5.993 Get:15 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [2152 kB]
#21 6.110 Get:16 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Packages [3669 kB]
#21 6.317 Get:17 http://archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 Packages [695 B]
#21 6.318 Get:18 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Packages [36.1 kB]
#21 6.318 Get:19 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Packages [49.5 kB]
#21 6.667 Fetched 37.5 MB in 6s (5876 kB/s)
#21 6.667 Reading package lists...
#21 7.765 Reading package lists...
#21 8.540 Building dependency tree...
#21 8.715 Reading state information...
#21 8.858 openssh-client is already the newest version (1:9.6p1-3ubuntu13.15).
#21 8.858 lsof is already the newest version (4.95.0-1build3).
#21 8.858 The following additional packages will be installed:
#21 8.859   libwrap0 openssh-sftp-server ucf
#21 8.859 Suggested packages:
#21 8.859   molly-guard monkeysphere ssh-askpass ufw
#21 8.859 Recommended packages:
#21 8.859   default-logind | logind | libpam-systemd ncurses-term xauth ssh-import-id
#21 8.900 The following NEW packages will be installed:
#21 8.901   libwrap0 openssh-server openssh-sftp-server ucf
#21 9.392 0 upgraded, 4 newly installed, 0 to remove and 0 not upgraded.
#21 9.392 Need to get 651 kB of archives.
#21 9.392 After this operation, 2575 kB of additional disk space will be used.
#21 9.392 Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 openssh-sftp-server amd64 1:9.6p1-3ubuntu13.15 [37.3 kB]
#21 9.987 Get:2 http://archive.ubuntu.com/ubuntu noble/main amd64 ucf all 3.0043+nmu1 [56.5 kB]
#21 10.26 Get:3 http://archive.ubuntu.com/ubuntu noble/main amd64 libwrap0 amd64 7.6.q-33 [47.9 kB]
#21 10.46 Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 openssh-server amd64 1:9.6p1-3ubuntu13.15 [510 kB]
#21 11.91 Preconfiguring packages ...
#21 11.98 Fetched 651 kB in 2s (308 kB/s)
#21 12.00 Selecting previously unselected package openssh-sftp-server.
(Reading database ... 22651 files and directories currently installed.)
#21 12.02 Preparing to unpack .../openssh-sftp-server_1%3a9.6p1-3ubuntu13.15_amd64.deb ...
#21 12.02 Unpacking openssh-sftp-server (1:9.6p1-3ubuntu13.15) ...
#21 12.05 Selecting previously unselected package ucf.
#21 12.06 Preparing to unpack .../ucf_3.0043+nmu1_all.deb ...
#21 12.06 Moving old data out of the way
#21 12.06 Unpacking ucf (3.0043+nmu1) ...
#21 12.10 Selecting previously unselected package libwrap0:amd64.
#21 12.10 Preparing to unpack .../libwrap0_7.6.q-33_amd64.deb ...
#21 12.10 Unpacking libwrap0:amd64 (7.6.q-33) ...
#21 12.13 Selecting previously unselected package openssh-server.
#21 12.14 Preparing to unpack .../openssh-server_1%3a9.6p1-3ubuntu13.15_amd64.deb ...
#21 12.14 Unpacking openssh-server (1:9.6p1-3ubuntu13.15) ...
#21 12.20 Setting up openssh-sftp-server (1:9.6p1-3ubuntu13.15) ...
#21 12.21 Setting up libwrap0:amd64 (7.6.q-33) ...
#21 12.22 Setting up ucf (3.0043+nmu1) ...
#21 12.30 Setting up openssh-server (1:9.6p1-3ubuntu13.15) ...
#21 12.41
#21 12.41 Creating config file /etc/ssh/sshd_config with new version
#21 12.45 Creating SSH2 RSA key; this may take some time ...
#21 13.53 3072 SHA256:nRyc+OKsY+5W20xka+T7VRL7n12FivRHd4psnFoYBgM root@buildkitsandbox (RSA)
#21 13.54 Creating SSH2 ECDSA key; this may take some time ...
#21 13.54 256 SHA256:Y9oht9AM0SHl9spou0mCbzWAnmlLzMLbvgXA+ZcGCQg root@buildkitsandbox (ECDSA)
#21 13.55 Creating SSH2 ED25519 key; this may take some time ...
#21 13.55 256 SHA256:NwUJxgz9+pRwcft+UgD4ddVP+rsdlAMwvbDTi9p1Wog root@buildkitsandbox (ED25519)
#21 13.74 invoke-rc.d: could not determine current runlevel
#21 13.75 invoke-rc.d: policy-rc.d denied execution of start.
#21 13.95 Processing triggers for man-db (2.12.0-4build2) ...
#21 14.07 Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
#21 14.11 adding 'ssh' group, as it does not already exist.
#21 14.16 Done!
#21 14.16
#21 14.16 - Port: 2222
#21 14.16 - User: vscode
#21 14.18
#21 14.18 Forward port 2222 to your local machine and run:
#21 14.18
#21 14.18   ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null vscode@localhost
#21 14.18
#21 DONE 14.2s

#22 [dev_containers_target_stage 15/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=jq-likes_10,target=/tmp/build-features-src/jq-likes_10     cp -ar /tmp/build-features-src/jq-likes_10 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/jq-likes_10  && cd /tmp/dev-container-features/jq-likes_10  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/jq-likes_10
#22 0.221 ===========================================================================
#22 0.221 Feature       : jq, yq, gojq, xq, jaq
#22 0.221 Description   : Installs jq and jq like command line tools (yq, gojq, xq, jaq).
#22 0.221 Id            : ghcr.io/eitsupi/devcontainer-features/jq-likes
#22 0.221 Version       : 2.1.1
#22 0.221 Documentation : ********/eitsupi/devcontainer-features/tree/main/src/jq-likes
#22 0.221 Options       :
#22 0.221     JQVERSION="latest"
#22 0.221     YQVERSION="4"
#22 0.221     GOJQVERSION="none"
#22 0.221     XQVERSION="none"
#22 0.221     JAQVERSION="none"
#22 0.221     ALLOWJQRCVERSION="false"
#22 0.221 ===========================================================================
#22 0.821 JQ_VERSION=1.8.1
#22 1.418 YQ_VERSION=4.52.5
#22 1.424 Downloading jq 1.8.1...
#22 1.795 Downloading yq 4.52.5...
#22 2.625 /tmp/yq /tmp/dev-container-features/jq-likes_10
#22 2.635 /tmp/dev-container-features/jq-likes_10
#22 2.641 Installing bash completion...
#22 2.653 Installing zsh completion...
#22 2.663 Done!
#22 DONE 2.9s

#23 [dev_containers_target_stage 16/16] RUN --mount=type=bind,from=dev_containers_feature_content_source,source=neovim_11,target=/tmp/build-features-src/neovim_11     cp -ar /tmp/build-features-src/neovim_11 /tmp/dev-container-features  && chmod -R 0755 /tmp/dev-container-features/neovim_11  && cd /tmp/dev-container-features/neovim_11  && chmod +x ./devcontainer-features-install.sh  && ./devcontainer-features-install.sh  && rm -rf /tmp/dev-container-features/neovim_11
#23 0.224 ===========================================================================
#23 0.224 Feature       : Neovim
#23 0.224 Description   : Installs Neovim Editor. See neovim.io
#23 0.224 Id            : ghcr.io/stu-bell/devcontainer-features/neovim
#23 0.224 Version       : 0.1.2
#23 0.224 Documentation :
#23 0.224 Options       :
#23 0.224     CONFIG_GIT_URL=""
#23 0.224     CONFIG_LOCATION="/config"
#23 0.224 ===========================================================================
#23 0.231 Installing neovim via appimage: https://neovim.io/doc/install/#appimage-universal-linux-package
#23 0.238   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#23 0.238                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 10.8M  100 10.8M    0     0   9.9M      0  0:00:01  0:00:01 --:--:-- 42.6M
#23 1.621 Neovim installed successfully:
#23 1.626 NVIM v0.12.0
#23 1.626 Build type: Release
#23 1.626 LuaJIT 2.1.1774638290
#23 1.626 Run "nvim -V1 -v" for more info
#23 DONE 2.2s

#24 preparing layers for inline cache
#24 DONE 10.1s

#25 exporting to image
#25 exporting layers done
#25 writing image sha256:b2d7a0251273caa341261817a99f991bbf9b75eb1c98f29536de98fbdc30464a done
#25 naming to docker.io/library/vsc-dotfiles-a27ca6b2102aafb81f317f594f8e65e53031b8ec9c85f8682cc9c6ac78502164-features done
#25 DONE 0.0s
[227843 ms] Stop: Run: docker buildx build --load --build-arg BUILDKIT_INLINE_CACHE=1 --build-context dev_containers_feature_content_source=/tmp/devcontainercli-root/container-features/0.83.3-1775365142913 --build-arg _DEV_CONTAINERS_BASE_IMAGE=mcr.microsoft.com/devcontainers/base:ubuntu-24.04 --build-arg _DEV_CONTAINERS_IMAGE_USER=root --build-arg _DEV_CONTAINERS_FEATURE_CONTENT_SOURCE=dev_container_feature_content_temp --target dev_containers_target_stage -f /tmp/devcontainercli-root/container-features/0.83.3-1775365142913/Dockerfile.extended -t vsc-dotfiles-a27ca6b2102aafb81f317f594f8e65e53031b8ec9c85f8682cc9c6ac78502164-features /var/lib/docker/codespacemount/.persistedshare/empty-folder
[240443 ms] Start: Run: docker run --sig-proxy=false -a STDOUT -a STDERR --mount type=bind,src=/var/lib/docker/codespacemount/workspace,dst=/workspaces --mount source=/root/.codespaces/shared,target=/workspaces/.codespaces/shared,type=bind --mount source=/var/lib/docker/codespacemount/.persistedshare,target=/workspaces/.codespaces/.persistedshare,type=bind --mount source=/.codespaces/agent/mount,target=/.codespaces/bin,type=bind --mount source=/mnt/containerTmp,target=/tmp,type=bind --mount type=bind,src=/.codespaces/agent/mount/cache,dst=/vscode -l Type=codespaces -e CODESPACES=******** -e ContainerVersion=13 -e RepositoryName=dotfiles --label ContainerVersion=13 --hostname codespaces-4aec7c --add-host codespaces-4aec7c:127.0.0.1 --cap-add sys_nice --network host --entrypoint /bin/sh vsc-dotfiles-a27ca6b2102aafb81f317f594f8e65e53031b8ec9c85f8682cc9c6ac78502164-features -c echo Container started
Container started
Outcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Running blocking commands...
$ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/dotfiles --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --user-data-folder /var/lib/docker/codespacemount/.persistedshare --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --omit-config-remote-env-from-metadata --skip-non-blocking-commands --expect-existing-container --config "/var/lib/docker/codespacemount/workspace/dotfiles/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json
[189 ms] @devcontainers/cli 0.83.3. Node.js v18.20.8. linux 6.8.0-1044-azure x64.
Outcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Configuring codespace...
Running commands...
$ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/dotfiles --expect-existing-container --skip-post-attach --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --config "/var/lib/docker/codespacemount/workspace/dotfiles/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json
[226 ms] @devcontainers/cli 0.83.3. Node.js v18.20.8. linux 6.8.0-1044-azure x64.
Running the postCreateCommand from devcontainer.json...

bash .devcontainer/post-install.sh
mise trusted /workspaces/dotfiles
[2026-04-05 05:03:06] [INFO] Setting up dotfiles...
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
mise WARN  Failed to resolve tool version list for npm:@aikidosec/safe-chain: [~/.config/mise/config.toml] npm:@aikidosec/safe-chain@1.4.7: No such file or directory (os error 2)
mise WARN  Failed to resolve tool version list for npm:neovim: [~/.config/mise/config.toml] npm:neovim@5.4.0: No such file or directory (os error 2)
mise WARN  Failed to resolve tool version list for npm:mcp-remote: [~/.config/mise/config.toml] npm:mcp-remote@0.1.38: No such file or directory (os error 2)
info: downloading installer
warn: It looks like you have an existing rustup settings file at:
warn: /home/vscode/.rustup/settings.toml
warn: Rustup will install the default toolchain as specified in the settings file,
warn: instead of the one inferred from the default host triple.
info: profile set to default
info: default host triple is x86_64-unknown-linux-gnu
info: skipping toolchain installation
info: syncing channel updates for 1.94.1-x86_64-unknown-linux-gnu
mise hint installing precompiled python from astral-sh/python-build-standalone
if you experience issues with this python (e.g.: running poetry), switch to python-build by running mise settings python.compile=1
info: latest update on 2026-03-26 for version 1.94.1 (e408947bf 2026-03-25)
info: downloading 6 components
mise Verifying "/home/vscode/.local/share/mise/downloads/lua-5.1.5/lua-5.1.5.tar.gz" checksum
mise Extracting "/home/vscode/.local/share/mise/downloads/lua-5.1.5/lua-5.1.5.tar.gz" to "/home/vscode/.local/share/mise/installs/lua/5.1.5"
mise 2026.4.4 by @jdx                                                     [1/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
pnpm@10.33.0                        download pnpm-linux-x64                    ◠
node@24.14.0                        download node-v… 0 B  [                  ] ◠
gpg: Signature made Tue Feb 24 15:33:35 2026 UTC
gpg:                using RSA key 108F52B48DB57BB0CC439B2997B01419BD92F80A
gpg: Good signature from "Ruy Adorno <ruyadorno@hotmail.com>" [unknown]
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        extract node-v24.14.0-linux-x64.tar.gz     ◠
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
mise Cannot parse Rekor public key with id cf1199155bddd051268d1f16ac5c0c75c009f6fb5a63f4177f8e18d7051e3fa0: Pkcs8 spki error : Ecdsa-P256 from der bytes to public key failed: unknown/unsupported algorithm OID: 1.2.840.10045.2.1
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
mise 2026.4.4 by @jdx                                                     [4/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
mise Cannot parse Rekor public key with id cf1199155bddd051268d1f16ac5c0c75c009f6fb5a63f4177f8e18d7051e3fa0: Pkcs8 spki error : Ecdsa-P256 from der bytes to public key failed: unknown/unsupported algorithm OID: 1.2.840.10045.2.1
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◞
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       extract cpython-3.14.3+20260324-x86_64…    ◞
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◞
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◡
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       extract cpython-3.14.3+20260324-x86_64…    ◡
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◡
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
mise 2026.4.4 by @jdx                                                     [6/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◜
mise 2026.4.4 by @jdx                                                     [6/17]
mise 2026.4.4 by @jdx                                                     [7/17]
mise 2026.4.4 by @jdx                                                     [7/17]
mise 2026.4.4 by @jdx                                                     [7/17]
mise 2026.4.4 by @jdx                                                     [7/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◞
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
mise 2026.4.4 by @jdx                                                     [7/17]
mise 2026.4.4 by @jdx                                                     [8/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◞
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
Resolved 3 packages in 326ms
Prepared 3 packages in 4.76s
Installed 3 packages in 44ms
 + greenlet==3.3.2
 + msgpack==1.1.2
 + pynvim==0.6.0
Installed 1 executable: pynvim-python
Resolved 42 packages in 5.34s
Resolved 69 packages in 5.39s
Downloading pygments (1.2MiB)
Downloading cryptography (4.3MiB)

Configuring LuaRocks version 3.13.0...

Lua version detected: 5.1
Lua interpreter found: /home/vscode/.local/share/mise/installs/lua/5.1.5/bin/lua
lua.h found: /home/vscode/.local/share/mise/installs/lua/5.1.5/include/lua.h
Downloading pydantic-core (2.0MiB)
unzip found in PATH: /usr/bin
Downloading cryptography (4.3MiB)
Downloading sympy (6.0MiB)
Downloading numpy (15.9MiB)
Downloading pdfminer-six (6.3MiB)
Downloading pypdfium2 (3.5MiB)
Downloading youtube-transcript-api (2.1MiB)
Downloading speechrecognition (31.3MiB)
Downloading onnxruntime (16.4MiB)
Downloading magika (14.7MiB)
Downloading pydantic-core (2.0MiB)
Downloading lxml (5.0MiB)
Downloading pillow (6.8MiB)
Downloading pandas (10.4MiB)
 Downloaded pydantic-core
mise 2026.4.4 by @jdx                                                    [11/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◜
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◜
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
uv@0.11.3                           extract uv-x86_64-unknown-linux-musl.tar.… ✔
npm:mcp-remote@0.1.38               Done in 16.7s using pnpm v10.33.0          ✔
npm:neovim@5.4.0                    Done in 15.4s using pnpm v10.33.0          ✔
npm:@aikidosec/safe-chain@1.4.7     Done in 15.2s using pnpm v10.33.0          ✔
pipx:markitdown-mcp@0.0.1a4         uv tool install markitdown-mcp==0.0.1a4    ◜
pipx:awslabs.aws-documentation-mcp-server@1.1.20 uv tool install awslabs.aws-… ◜
mise 2026.4.4 by @jdx                                                    [12/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◜
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◜
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
 Downloaded cryptography
mise 2026.4.4 by @jdx                                                    [12/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
rust@1.94.1                         source "$HOME/.cargo/env.xsh"   # For …    ◠
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
uv@0.11.3                           extract uv-x86_64-unknown-linux-musl.tar.… ✔
npm:mcp-remote@0.1.38               Done in 16.7s using pnpm v10.33.0          ✔
npm:neovim@5.4.0                    Done in 15.4s using pnpm v10.33.0          ✔
 Downloaded pygments
Prepared 42 packages in 2.22s
mise 2026.4.4 by @jdx                                                    [12/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
Installed 42 packages in 160ms
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
 Downloaded pydantic-core
 Downloaded youtube-transcript-api
 Downloaded pypdfium2
 Downloaded pdfminer-six
 Downloaded cryptography
 Downloaded pillow
 Downloaded lxml
 Downloaded magika
 Downloaded numpy
 Downloaded speechrecognition
mise 2026.4.4 by @jdx                                                    [13/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ◠
 Downloaded onnxruntime
 Downloaded sympy
 Downloaded pandas
Prepared 69 packages in 5.71s
Installed 69 packages in 307ms
 + annotated-types==0.7.0
 + anyio==4.13.0
 + audioop-lts==0.2.2
 + azure-ai-documentintelligence==1.0.2
 + azure-core==1.39.0
 + azure-identity==1.25.3
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
Installed 1 executable: markitdown-mcp
info: default toolchain set to 1.94.1-x86_64-unknown-linux-gnu
info: checking for self-update (current version: 1.29.0)
    Updating crates.io index
 Downloading crates ...
  Downloaded tree-sitter-cli v0.26.8
  Installing tree-sitter-cli v0.26.8
    Updating crates.io index
    Updating crates.io index
 Downloading crates ...
  Downloaded httpdate v1.0.3
  Downloaded ref-cast-impl v1.0.25
  Downloaded rand_chacha v0.3.1
  Downloaded shlex v1.3.0
  Downloaded ref-cast v1.0.25
  Downloaded relative-path v2.0.1
  Downloaded regex-syntax v0.8.10
  Downloaded tree-sitter-tags v0.26.8
  Downloaded zerocopy v0.8.39
  Downloaded zeroize v1.8.2
  Downloaded utf8parse v0.2.2
  Downloaded zerovec-derive v0.11.2
  Downloaded zmij v1.0.21
  Downloaded zerotrie v0.2.3
  Downloaded unicode-ident v1.0.24
  Downloaded zerovec v0.11.5
  Downloaded schemars v1.2.1
  Downloaded unicode-segmentation v1.12.0
  Downloaded tree-sitter v0.26.8
  Downloaded rquickjs-core v0.10.0
  Downloaded serde_json v1.0.149
  Downloaded winnow v0.7.14
  Downloaded nix v0.31.1
  Downloaded wasmparser v0.243.0
  Downloaded icu_normalizer_data v2.1.1
  Downloaded unicode-width v0.2.2
  Downloaded rand v0.8.5
  Downloaded syn v2.0.117
  Downloaded icu_locale_core v2.1.1
  Downloaded libc v0.2.180
  Downloaded prettyplease v0.2.37
  Downloaded hashbrown v0.15.5
  Downloaded tree-sitter-generate v0.26.8
  Downloaded rustix v1.1.3
  Downloaded rustix v0.38.44
  Downloaded serde_core v1.0.228
  Downloaded toml_edit v0.23.10+spec-1.0.0
  Downloaded tiny_http v0.12.0
  Downloaded thiserror-impl v2.0.18
  Downloaded serde_derive v1.0.228
  Downloaded serde v1.0.228
  Downloaded linux-raw-sys v0.11.0
  Downloaded bindgen v0.72.1
  Downloaded webbrowser v1.1.0
  Downloaded smallvec v1.15.1
  Downloaded similar v2.7.0
  Downloaded tree-sitter-loader v0.26.8
  Downloaded thiserror v2.0.18
  Downloaded tempfile v3.25.0
  Downloaded synstructure v0.13.2
  Downloaded serde_derive_internals v0.29.1
  Downloaded rustversion v1.0.22
  Downloaded rquickjs v0.10.0
  Downloaded yoke v0.8.1
  Downloaded walkdir v2.5.0
  Downloaded thiserror v1.0.69
  Downloaded streaming-iterator v0.1.9
  Downloaded rquickjs-macro v0.10.0
  Downloaded allocator-api2 v0.2.21
  Downloaded regex-automata v0.4.14
  Downloaded rquickjs-sys v0.10.0
  Downloaded utf8_iter v1.0.4
  Downloaded utf8-width v0.1.8
  Downloaded tree-sitter-language v0.1.7
  Downloaded tree-sitter-config v0.26.8
  Downloaded topological-sort v0.2.2
  Downloaded stable_deref_trait v1.2.1
  Downloaded smallbitvec v2.6.0
  Downloaded siphasher v1.0.2
  Downloaded shell-words v1.1.1
  Downloaded schemars_derive v1.2.1
  Downloaded rgb v0.8.52
  Downloaded log v0.4.29
  Downloaded ident_case v1.0.1
  Downloaded icu_provider v2.1.1
  Downloaded icu_properties v2.1.2
  Downloaded glob v0.3.3
  Downloaded getrandom v0.2.17
  Downloaded foldhash v0.2.0
  Downloaded console v0.15.11
  Downloaded zerofrom-derive v0.1.6
  Downloaded zerofrom v0.1.6
  Downloaded writeable v0.6.2
  Downloaded url v2.5.8
  Downloaded tree-sitter-highlight v0.26.8
  Downloaded toml_parser v1.0.9+spec-1.1.0
  Downloaded tinystr v0.8.2
  Downloaded thread_local v1.1.9
  Downloaded thiserror-impl v1.0.69
  Downloaded strsim v0.11.1
  Downloaded semver v1.0.27
  Downloaded same-file v1.0.6
  Downloaded rustc-hash v2.1.1
  Downloaded linux-raw-sys v0.4.15
  Downloaded phf v0.13.1
  Downloaded minimal-lexical v0.2.1
  Downloaded litemap v0.8.1
  Downloaded indoc v2.0.7
  Downloaded idna_adapter v1.2.1
  Downloaded form_urlencoded v1.2.2
  Downloaded foldhash v0.1.5
  Downloaded ctor v0.2.9
  Downloaded convert_case v0.8.0
  Downloaded clap_complete_nushell v4.5.10
  Downloaded yoke-derive v0.8.1
  Downloaded proc-macro-crate v3.4.0
  Downloaded itoa v1.0.17
  Downloaded heck v0.5.0
  Downloaded fnv v1.0.7
  Downloaded etcetera v0.11.0
  Downloaded ctrlc v3.5.2
  Downloaded clap v4.5.60
  Downloaded toml_datetime v0.7.5+spec-1.1.0
  Downloaded regex v1.12.3
  Downloaded phf_shared v0.13.1
  Downloaded pathdiff v0.2.3
  Downloaded icu_collections v2.1.1
  Downloaded html-escape v0.2.13
  Downloaded fuzzy-matcher v0.3.7
  Downloaded dunce v1.0.5
  Downloaded anyhow v1.0.102
  Downloaded anstyle v1.0.13
  Downloaded rand_core v0.6.4
  Downloaded quote v1.0.44
  Downloaded libloading v0.9.0
  Downloaded displaydoc v0.2.5
  Downloaded bitflags v2.11.0
  Downloaded potential_utf v0.1.4
  Downloaded is_terminal_polyfill v1.70.2
  Downloaded fastrand v2.3.0
  Downloaded either v1.15.0
  Downloaded clap_lex v1.0.0
  Downloaded clang-sys v1.8.1
  Downloaded cfg_aliases v0.2.1
  Downloaded cfg-if v1.0.4
  Downloaded bytemuck v1.25.0
  Downloaded bstr v1.12.1
  Downloaded anstyle-query v1.1.5
  Downloaded once_cell v1.21.3
  Downloaded memchr v2.8.0
  Downloaded icu_properties_data v2.1.2
  Downloaded icu_normalizer v2.1.1
  Downloaded clap_complete v4.5.66
  Downloaded clap_builder v4.5.60
  Downloaded ansi_colours v1.2.3
  Downloaded nom v7.1.3
  Downloaded indexmap v2.13.0
  Downloaded hashbrown v0.16.1
  Downloaded equivalent v1.0.2
  Downloaded colorchoice v1.0.4
  Downloaded aho-corasick v1.1.4
  Downloaded proc-macro2 v1.0.106
  Downloaded itertools v0.13.0
  Downloaded idna v1.1.0
  Downloaded getrandom v0.4.1
  Downloaded find-msvc-tools v0.1.9
  Downloaded dyn-clone v1.0.20
  Downloaded crc32fast v1.5.0
  Downloaded clap_derive v4.5.55
  Downloaded cc v1.2.56
  Downloaded ppv-lite86 v0.2.21
  Downloaded phf_generator v0.13.1
  Downloaded percent-encoding v2.3.2
  Downloaded libloading v0.8.9
  Downloaded fs4 v0.12.0
  Downloaded errno v0.3.14
  Downloaded dialoguer v0.11.0
  Downloaded chunked_transfer v1.5.0
  Downloaded cexpr v0.6.0
  Downloaded ascii v1.1.0
  Downloaded anstyle-parse v0.2.7
  Downloaded anstream v0.6.21
   Compiling proc-macro2 v1.0.106
   Compiling unicode-ident v1.0.24
   Compiling quote v1.0.44
   Compiling memchr v2.8.0
   Compiling shlex v1.3.0
   Compiling find-msvc-tools v0.1.9
   Compiling foldhash v0.2.0
   Compiling cc v1.2.56
   Compiling allocator-api2 v0.2.21
   Compiling equivalent v1.0.2
   Compiling zmij v1.0.21
   Compiling hashbrown v0.16.1
   Compiling cfg-if v1.0.4
   Compiling glob v0.3.3
   Compiling libc v0.2.180
   Compiling stable_deref_trait v1.2.1
   Compiling prettyplease v0.2.37
   Compiling clang-sys v1.8.1
   Compiling regex-syntax v0.8.10
   Compiling indexmap v2.13.0
   Compiling syn v2.0.117
   Compiling minimal-lexical v0.2.1
   Compiling libloading v0.8.9
   Compiling nom v7.1.3
   Compiling regex-automata v0.4.14
   Compiling either v1.15.0
   Compiling serde_core v1.0.228
   Compiling bindgen v0.72.1
   Compiling itertools v0.13.0
   Compiling cexpr v0.6.0
   Compiling regex v1.12.3
   Compiling rustc-hash v2.1.1
   Compiling synstructure v0.13.2
   Compiling bitflags v2.11.0
   Compiling log v0.4.29
   Compiling zerofrom-derive v0.1.6
   Compiling yoke-derive v0.8.1
   Compiling zerovec-derive v0.11.2
   Compiling displaydoc v0.2.5
   Compiling serde_json v1.0.149
   Compiling zerofrom v0.1.6
   Compiling yoke v0.8.1
   Compiling zerovec v0.11.5
   Compiling tree-sitter-language v0.1.7
   Compiling itoa v1.0.17
   Compiling aho-corasick v1.1.4
   Compiling serde v1.0.228
   Compiling tinystr v0.8.2
   Compiling writeable v0.6.2
   Compiling litemap v0.8.1
   Compiling icu_locale_core v2.1.1
   Compiling tree-sitter v0.26.8
   Compiling rquickjs-sys v0.10.0
   Compiling potential_utf v0.1.4
   Compiling zerotrie v0.2.3
   Compiling serde_derive v1.0.228
   Compiling icu_properties_data v2.1.2
   Compiling thiserror v2.0.18
   Compiling icu_normalizer_data v2.1.1
   Compiling icu_provider v2.1.1
   Compiling icu_collections v2.1.1
   Compiling thiserror-impl v2.0.18
   Compiling utf8parse v0.2.2
   Compiling winnow v0.7.14
   Compiling anstyle-parse v0.2.7
   Compiling toml_parser v1.0.9+spec-1.1.0
   Compiling zerocopy v0.8.39
   Compiling toml_datetime v0.7.5+spec-1.1.0
   Compiling siphasher v1.0.2
   Compiling rustix v1.1.3
   Compiling getrandom v0.4.1
   Compiling smallvec v1.15.1
   Compiling is_terminal_polyfill v1.70.2
   Compiling colorchoice v1.0.4
   Compiling anstyle-query v1.1.5
   Compiling anstyle v1.0.13
   Compiling icu_normalizer v2.1.1
   Compiling anstream v0.6.21
   Compiling phf_shared v0.13.1
   Compiling toml_edit v0.23.10+spec-1.0.0
   Compiling icu_properties v2.1.2
   Compiling clap_lex v1.0.0
   Compiling rustix v0.38.44
   Compiling streaming-iterator v0.1.9
   Compiling unicode-segmentation v1.12.0
   Compiling relative-path v2.0.1
   Compiling fastrand v2.3.0
   Compiling once_cell v1.21.3
   Compiling heck v0.5.0
   Compiling linux-raw-sys v0.11.0
   Compiling strsim v0.11.1
   Compiling cfg_aliases v0.2.1
   Compiling nix v0.31.1
   Compiling clap_builder v4.5.60
   Compiling clap_derive v4.5.55
   Compiling phf_generator v0.13.1
   Compiling convert_case v0.8.0
   Compiling idna_adapter v1.2.1
   Compiling proc-macro-crate v3.4.0
   Compiling phf v0.13.1
   Compiling semver v1.0.27
   Compiling getrandom v0.2.17
   Compiling fnv v1.0.7
   Compiling ident_case v1.0.1
   Compiling ref-cast v1.0.25
   Compiling thiserror v1.0.69
   Compiling utf8_iter v1.0.4
   Compiling linux-raw-sys v0.4.15
   Compiling percent-encoding v2.3.2
   Compiling tempfile v3.25.0
   Compiling form_urlencoded v1.2.2
   Compiling idna v1.1.0
   Compiling ppv-lite86 v0.2.21
   Compiling rand_core v0.6.4
   Compiling clap v4.5.60
   Compiling thiserror-impl v1.0.69
   Compiling ref-cast-impl v1.0.25
   Compiling serde_derive_internals v0.29.1
   Compiling etcetera v0.11.0
   Compiling thread_local v1.1.9
   Compiling crc32fast v1.5.0
   Compiling wasmparser v0.243.0
   Compiling unicode-width v0.2.2
   Compiling foldhash v0.1.5
   Compiling tree-sitter-loader v0.26.8
   Compiling anyhow v1.0.102
   Compiling indoc v2.0.7
   Compiling rquickjs-core v0.10.0
   Compiling bytemuck v1.25.0
   Compiling hashbrown v0.15.5
   Compiling rgb v0.8.52
   Compiling console v0.15.11
   Compiling schemars_derive v1.2.1
   Compiling rquickjs-macro v0.10.0
   Compiling fuzzy-matcher v0.3.7
   Compiling clap_complete v4.5.66
   Compiling rand_chacha v0.3.1
   Compiling url v2.5.8
   Compiling fs4 v0.12.0
   Compiling tree-sitter-highlight v0.26.8
   Compiling tree-sitter-tags v0.26.8
   Compiling libloading v0.9.0
   Compiling same-file v1.0.6
   Compiling pathdiff v0.2.3
   Compiling utf8-width v0.1.8
   Compiling smallbitvec v2.6.0
   Compiling zeroize v1.8.2
   Compiling shell-words v1.1.1
   Compiling chunked_transfer v1.5.0
   Compiling tree-sitter-cli v0.26.8
   Compiling dyn-clone v1.0.20
   Compiling ascii v1.1.0
   Compiling topological-sort v0.2.2
   Compiling dunce v1.0.5
   Compiling httpdate v1.0.3
   Compiling schemars v1.2.1
   Compiling tiny_http v0.12.0
   Compiling dialoguer v0.11.0
   Compiling html-escape v0.2.13
   Compiling walkdir v2.5.0
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
    Finished `release` profile [optimized] target(s) in 2m 18s
  Installing /home/vscode/.local/share/mise/installs/cargo-tree-sitter-cli/0.26.8/bin/tree-sitter
   Installed package `tree-sitter-cli v0.26.8` (executable `tree-sitter`)
warning: be sure to add `/home/vscode/.local/share/mise/installs/cargo-tree-sitter-cli/0.26.8/bin` to your PATH to be able to run the installed binaries
mise 2026.4.4 by @jdx                                                    [17/17]
cargo-binstall@1.17.9               extract cargo-binstall-x86_64-unknown-lin… ✔
lua@5.1.5                           install                                    ✔
pnpm@10.33.0                        extract pnpm-linux-x64                     ✔
node@24.14.0                        11.9.0                                     ✔
python@3.14.3                       Python 3.14.3                              ✔
rust@1.94.1                         rustc 1.94.1 (e408947bf 2026-03-25)        ✔
shellcheck@0.11.0                   extract shellcheck-v0.11.0.linux.x86_64.t… ✔
go@1.26.1                           go version go1.26.1 linux/amd64            ✔
shfmt@3.13.0                        extract shfmt_v3.13.0_linux_amd64          ✔
uv@0.11.3                           extract uv-x86_64-unknown-linux-musl.tar.… ✔
npm:mcp-remote@0.1.38               Done in 16.7s using pnpm v10.33.0          ✔
npm:neovim@5.4.0                    Done in 15.4s using pnpm v10.33.0          ✔
npm:@aikidosec/safe-chain@1.4.7     Done in 15.2s using pnpm v10.33.0          ✔
pipx:markitdown-mcp@0.0.1a4         uv tool install markitdown-mcp==0.0.1a4    ✔
pipx:awslabs.aws-documentation-mcp-server@1.1.20 uv tool install awslabs.aws-… ✔
pipx:pynvim@0.6.0                   uv tool install pynvim==0.6.0              ✔
cargo:tree-sitter-cli@0.26.8         INFO Done in 141.610603935s               ✔
mise all tools are installed
[2026-04-05 05:06:32] [INFO] Setting up Neovim...
[2026-04-05 05:06:32] [INFO] Bootstrapping lazy.nvim...
Cloning into '/home/vscode/.local/share/nvim/lazy/lazy.nvim'...
remote: Enumerating objects: 8166, done.
remote: Counting objects: 100% (1150/1150), done.
remote: Compressing objects: 100% (74/74), done.
remote: Total 8166 (delta 1119), reused 1076 (delta 1076), pack-reused 7016 (from 2)
Receiving objects: 100% (8166/8166), 1.62 MiB | 27.70 MiB/s, done.
Resolving deltas: 100% (4421/4421), done.
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
Receiving objects: 100% (97/97), 258.69 KiB | 3.64 MiB/s, done.
[2026-04-05 05:06:34] [INFO] Checking Neovim init...
lazypath=/home/vscode/.local/share/nvim/lazy/lazy.nvim, dir_exists=********, in_rtp=false, require_lazy=false, err=module 'lazy' not found:
        no field package.preload['lazy']
        no file './lazy.lua'
        no file '/home/runner/work/neovim/neovim/.deps/usr/share/luajit-2.1/lazy.lua'
        no file '/usr/local/share/lua/5.1/lazy.lua'
        no file '/usr/local/share/lua/5.1/lazy/init.lua'
        no file '/home/runner/work/neovim/neovim/.deps/usr/share/lua/5.1/lazy.lua'
        no file '/home/runner/work/neovim/neovim/.deps/usr/share/lua/5.1/lazy/init.lua'
        no file './lazy.so'
        no file '/usr/local/lib/lua/5.1/lazy.so'
        no file '/home/runner/work/neovim/neovim/.deps/usr/lib/lua/5.1/lazy.so'
        no file '/usr/local/lib/lua/5.1/loadall.so', :Lazy=false
Error in command line:
E492: Not an editor command: Lazy! syncError in command line:
E492: Not an editor command: MasonToolsInstallSyncError in command line:
E492: Not an editor command: TSUpdateSyncOutcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Installing dotfiles...
$ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/dotfiles --expect-existing-container --skip-post-attach --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --config "/var/lib/docker/codespacemount/workspace/dotfiles/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --dotfiles-repository https://github.com/iimuz/dotfiles --dotfiles-target-path /workspaces/.codespaces/.persistedshare/dotfiles --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json
[146 ms] @devcontainers/cli 0.83.3. Node.js v18.20.8. linux 6.8.0-1044-azure x64.
[437 ms] Start: Run in container: # Clone & install dotfiles
[442 ms] Cloning into '/workspaces/.codespaces/.persistedshare/dotfiles'...

[1282 ms] Setting current directory to /workspaces/.codespaces/.persistedshare/dotfiles

[1284 ms] Linking dotfiles: /workspaces/.codespaces/.persistedshare/dotfiles/.config /workspaces/.codespaces/.persistedshare/dotfiles/.devcontainer /workspaces/.codespaces/.persistedshare/dotfiles/.editorconfig /workspaces/.codespaces/.persistedshare/dotfiles/.gitconfig /workspaces/.codespaces/.persistedshare/dotfiles/.github /workspaces/.codespaces/.persistedshare/dotfiles/.gitignore /workspaces/.codespaces/.persistedshare/dotfiles/.inputrc /workspaces/.codespaces/.persistedshare/dotfiles/.markdownlint-cli2.yaml /workspaces/.codespaces/.persistedshare/dotfiles/.mise /workspaces/.codespaces/.persistedshare/dotfiles/.prettierrc.yml /workspaces/.codespaces/.persistedshare/dotfiles/.shellcheckrc /workspaces/.codespaces/.persistedshare/dotfiles/.tmux.conf

[1288 ms]
[1288 ms]
[1288 ms] Exit code 1
[851 ms] Stop: Run in container: # Clone & install dotfiles
Outcome: success User: vscode WorkspaceFolder: /workspaces/dotfiles
devcontainer process exited with exit code 0
Finished configuring codespace.
```

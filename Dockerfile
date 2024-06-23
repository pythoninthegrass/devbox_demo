# syntax=docker/dockerfile:1.7

FROM debian:12.5-slim

ARG USERNAME=appuser
ENV DEVBOX_USER=${USERNAME}
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG WORKDIR=/code

RUN <<EOF
#!/usr/bin/env bash
# Create the user
groupadd --gid $USER_GID $USERNAME
useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
apt-get update && apt-get install -y \
    --no-install-recommends ca-certificates curl sudo xz-utils
apt-get clean -y
rm -rf /var/lib/apt/lists/*
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
EOF

RUN <<EOF
#!/usr/bin/env bash
# Install devbox
curl -LJ https://get.jetify.com/devbox -o /tmp/install_devbox.sh
chmod +x /tmp/install_devbox.sh
/tmp/install_devbox.sh -f
chown -R ${USERNAME}:${USER_GID} $(which devbox)
EOF

WORKDIR ${WORKDIR}

RUN chown ${USER_UID}:${USER_GID} ${WORKDIR}

COPY --chown=${USER_UID}:${USER_GID} devbox.json .
COPY --chown=${USER_UID}:${USER_GID} devbox.lock .
COPY --chown=${USER_UID}:${USER_GID} pyproject.toml .
COPY --chown=${USER_UID}:${USER_GID} poetry.lock .
COPY --chown=${USER_UID}:${USER_GID} requirements.txt .

USER ${USERNAME}:${USER_GID}

ENV PATH="/home/${USERNAME}/.nix-profile/bin:${PATH}"

VOLUME ${WORKDIR}

CMD ["devbox", "shell"]

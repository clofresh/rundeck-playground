FROM rundeck/rundeck:SNAPSHOT

COPY --chown=rundeck:root ssh /home/rundeck/.ssh
RUN chmod 0700 /home/rundeck/.ssh \
    && chmod 0600 /home/rundeck/.ssh/* \
    && chmod 0644 /home/rundeck/.ssh/*.pub
RUN ls -lah /home/rundeck/.ssh
COPY --chown=rundeck:root nodes.yaml /home/rundeck/

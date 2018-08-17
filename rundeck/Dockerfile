FROM rundeck/rundeck:SNAPSHOT

COPY --chown=rundeck:rundeck ssh /home/rundeck/.ssh
RUN chmod 0700 /home/rundeck/.ssh \
    && chmod 0600 /home/rundeck/.ssh/* \
    && chmod 0644 /home/rundeck/.ssh/*.pub
COPY --chown=rundeck:rundeck nodes.yaml /home/rundeck/
COPY --chown=rundeck:rundeck libext/* /home/rundeck/libext/

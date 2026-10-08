(use-modules (guix)
             (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mattermost
  (package
    (name "mattermost")
    (version "11.7.12")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "08pycrnfiab3wkhpdlm20vdbcfmsm1savghja9ajlmwyy35yq44x"))))
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 'substitute-mostlymatter
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((mostlymatter-bin (assoc-ref inputs "mostlymatter")))
                (copy-file mostlymatter-bin "bin/mattermost")))))))
    (build-system copy-build-system)
    (inputs (list
             (list "mostlymatter"
              (origin
                (method url-fetch)
                (uri (string-append
                      "https://packages.framasoft.org/projects/mostlymatter/mostlymatter-amd64-v"
                      version))
                (file-name "mostlymatter")
                (sha256
                 (base32 "0cn4hsmlb5bxsxqrvj0fxapwgkkzwbpa58r0l0xw529fqj803xky"))))))
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

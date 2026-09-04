(use-modules (guix)
             (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mattermost
  (package
    (name "mattermost")
    (version "11.7.10")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "0w72h49hi47ax8abn1as0i3m70jvyfi5dcirvv7f846kvpvvcrmv"))))
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
                 (base32 "0m6l4kmxydnda7r6g6kjx4iq49aicdl51175s5ylpzpsq6w7dlnx"))))))
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

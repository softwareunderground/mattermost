(use-modules (guix)
             (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mattermost
  (package
    (name "mattermost")
    (version "11.7.5")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "1szwbhh317s0cfmmi8ahyia0fp1mnzrrwpzyl7r46zqrmnx9093s"))))
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
                 (base32 "1md1xff371khd3ivmc0i78nyz414zc131m6an7c04m10am99jg4b"))))))
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

(use-modules (guix)
             (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mostlymatter
  (package
    (name "mostlymatter")
    (version "11.7.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://packages.framasoft.org/projects/mostlymatter/mostlymatter-amd64-v"
              version))
        (sha256
          (base32 "0kx1397g100k6gh36m7vz2k02fgwf3lxvga45pz4l7j2wfphkb5m"))))
    (build-system copy-build-system)
    (synopsis "mostlymatter server")
    (description "mostlymatter server, a less hostile mattermost fork")
    (home-page "https://framagit.org/framasoft/framateam/mostlymatter/")
    (license expat)))

(define-public mattermost
  (package
    (name "mattermost")
    (version "11.7.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "1i8332z8q6kjh5x3prw2asgifrbgrs36fdzh66dpi2wvxh2vkrqj"))))
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'install 'substitute-mostlymatter
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((mostlymatter-dir (assoc-ref inputs "mostlymatter"))
                     (mostlymatter-bin (car (find-files mostlymatter-dir "mostlymatter"))))
                (copy-file mostlymatter-bin "bin/mattermost")))))))
    (build-system copy-build-system)
    (inputs (list mostlymatter))
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

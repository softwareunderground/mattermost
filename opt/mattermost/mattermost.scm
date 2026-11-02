(use-modules (guix)
             (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mattermost
  (package
    (name "mattermost")
    (version "11.7.14")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "1lcj6shzri9kqm3a821snsd5xmbzbh131w6spalfw26x9ivv1x9i"))))
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
                 (base32 "08bv0z9kqbadyrrwjbpphq4fvawxqsmirapqdf3whn310zmnk7c4"))))))
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

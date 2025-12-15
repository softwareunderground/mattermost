(use-modules (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mattermost
  (package
    (name "mattermost")
    (version "10.11.8")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "19xfk9h49nwkw07parzlhw20gq74c8g2i7wsic185nlk5fy0dnfh"))))
    (build-system copy-build-system)
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

(use-modules (guix packages)
             (guix download)
             (guix build-system copy)
             (guix licenses))

(define-public mattermost
  (package
    (name "mattermost")
    (version "10.5.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://releases.mattermost.com/" version
                            "/mattermost-" version "-linux-amd64.tar.gz"))
        (sha256
          (base32 "1rkyrp9ds3by5mi9bj63a6vjcw086qgbksjl8gdbn9a5srb0bbwm"))))
    (build-system copy-build-system)
    (synopsis "mattermost server")
    (description "mattermost server")
    (home-page "mattermost.com")
    (license expat)))

mattermost

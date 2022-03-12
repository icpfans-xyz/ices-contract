let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.7-20210818/package-set.dhall sha256:c4bd3b9ffaf6b48d21841545306d9f69b57e79ce3b1ac5e1f63b068ca4f89957
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  additions =
      [{ name = "ices"
      , repo = "https://github.com/icpfans-xyz/ices-motoko-library"
      , version = "v0.1.0"
      , dependencies = [] : List Text
      }] : List Package

in  upstream # additions
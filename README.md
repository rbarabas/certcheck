# certcheck
Simple cert checker script

# REQUIREMENTS
- Bash shell
- On OSX the coreutils package for GNU date
```
$ brew install coreutils
```

# SYNOPSIS

## Check if google.com domain will expire within 100 days:
```
~/src/certcheck main*
❯ ./certcheck.sh -d google.com -t 100
[!] google.com is about to expire in 59 days!!!

~/src/certcheck main*
❯ echo $?
1
```

## Add more verbosity
```
~/src/certcheck main*
❯ ./certcheck.sh -d google.com -t 100 -v
[i] loglevel at 1
[i] expiration threshold at 100
[!] google.com is about to expire in 59 days!!!
```

## Add even more verbosity for debug mode
```
~/src/certcheck main*
❯ ./certcheck.sh -d google.com -t 100 -vv
[i] loglevel at 2
[i] expiration threshold at 100
[*] end date: Jan 24 02:19:51 2022 GMT
[*] end date in seconds: 1642990791
[*] seconds left until expiry: 5131487
[*] days left until expiry: 59
[!] google.com is about to expire in 59 days!!!
```

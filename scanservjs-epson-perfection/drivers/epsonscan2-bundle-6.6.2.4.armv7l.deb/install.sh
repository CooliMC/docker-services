#! /bin/sh
#  Copyright (C) 2018  SEIKO EPSON CORPORATION
#
#  License: GPL-3.0+
#  Author : SEIKO EPSON CORPORATION
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License or, at
#  your option, any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#  You ought to have received a copy of the GNU General Public License
#  along with this package.  If not, see <http://www.gnu.org/licenses/>.

#   Convenience functions to deal with *.deb packages

# Given a list of possibly versioned dependency alternatives, echo the
# name of the preferred package to install if the dependency isn't met
# already.  If the dependency is met, the empty string will be output.
# This only works for dependencies that aim to add packages: Depends:,
# Recommends: and Suggests:.
# BUGS: The algorithm does not consider Provides:.
#
deb_to_install () {

    candidate=

    echo $* \
        | sed 's/[()]//g; s/|/\n/g' \
        | { while read pkg op ver; do

                case "$pkg" in
                    epsonscan2*)    continue;;
                esac

                inst=$(dpkg-query -W -f '${Version}' $pkg 2>/dev/null \
                         || true)       # so we can run with set -e

                if test -z "$inst"; then
                    : ${candidate:=$pkg}
                    continue
                fi

                if test -z "$ver"; then
                    candidate=
                    break
                fi

                if dpkg --compare-versions "$inst" "$op" "$ver"; then
                    candidate=
                    break
                fi

                : ${candidate:=$pkg}

            done

            echo ${candidate}
    }
}

# Output the names of all packages that are listed as a requirement
# (in a Depends:, Recommends: or Suggests: field) but not installed
# yet.
#
deb_requires () {

    package=$1
    require=$2

    depends=

    dpkg-deb -f $package ${require:-Depends} \
        | sed 's/,/\n/g' \
        | { while read dependency; do

                pkg=$(deb_to_install $dependency)
                test -n "$pkg" && depends="$depends $pkg"

            done

            echo $depends
    }
}

# Install all local *.deb files passed as arguments, resolving their
# dependencies without user intervention.
#
deb_install () {

    packages=$*

    depends=

    add_recommends=false
    result=$(apt-config shell add_recommends APT::Install-Recommends/b)
    eval $result

    add_suggests=false
    result=$(apt-config shell add_suggests APT::Install-Suggests/b)
    eval $result

    for pkg in $packages; do

        depends="$depends $(deb_requires $pkg)"

        if $add_recommends; then
            depends="$depends $(deb_requires $pkg Recommends)"
        fi

        if $add_suggests; then
            depends="$depends $(deb_requires $pkg Suggests)"
        fi

    done

    depends="$(echo $depends | sed 's|^ *||; s| *$||')"
    if test -z "$depends"; then
        as_root dpkg --install $packages
    else
        as_root apt-get update \
            && as_root apt-get install --assume-yes $depends \
            && as_root dpkg --install $packages
    fi
}

#   Convenience functions to deal with *.rpm packages

# Install all local *.rpm files passed as arguments, resolving their
# dependencies without user intervention.
#
rpm_install () {

    packages=$*

    pkg_mgr=

    for candidate in zypper dnf yum /usr/sbin/urpmi; do

        if type $candidate >/dev/null 2>&1; then
            pkg_mgr=$candidate
            break
        fi

    done

    case "$(basename $pkg_mgr)" in
        zypper)
            as_root $pkg_mgr --non-interactive --no-gpg-checks install $packages
            ;;
        urpmi)
            as_root $pkg_mgr --auto $packages
            ;;
        dnf|yum)
            as_root $pkg_mgr install --assumeyes $packages
            ;;
        *)
            echo "cannot find a supported package manager" >&2
            exit 1
            ;;
    esac
}

# 

# Run a command with root privileges.
#
as_root () {

    if test -z "$as_root" -a 0 -ne $(id -u) -a -z "$SUDO_USER"; then
        if $(type sudo >/dev/null 2>&1); then
            as_root=sudo
            if $($as_root -A true 2>/dev/null); then
                as_root="$as_root -A"
            fi
        fi
    fi

    $as_root "$@"
}

# 

SHOW_HELP=no
WITH_NETWORK=true
WITH_OCR_ENGINE=true

base=$(dirname $0)
core=$base/core
data=$base/data
plugins=$base/plugins

usage () {
    cat <<EOF
'$(basename $0)'

Usage: $0 --help
       $0 {--dry-run} [--with-network|--without-network]

The following options are supported:

  -h, --help            display this message and exit
  --dry-run             show what would be installed without actually
                        doing so
  --with-network        install the (non-free) network plugin
                        This is the default behavior.
  --without-network     do not install the (non-free) network plugin
  --with-ocr-engine     install the (non-free) OCR engine
                        This is the default behavior.
  --without-ocr-engine  do not install the (non-free) OCR engine
EOF
    exit $1
}

parsed_opts=$(getopt \
    --options h \
    --longopt help \
    --longopt dry-run \
    --longopt with-network,without-network \
    --longopt with-ocr-engine,without-ocr-engine \
    -- "$@")

if test 0 -ne $?; then
    usage 1
fi

eval set -- "$parsed_opts"

while test x-- != "x$1"; do
    case "$1" in
        -h|--help)             SHOW_HELP=yes; shift;;
        --dry-run)             as_root=echo; shift;;
        --with-network)        WITH_NETWORK=true; shift;;
        --without-network)     WITH_NETWORK=false; shift;;
        --with-ocr-engine)     WITH_OCR_ENGINE=true; shift;;
        --without-ocr-engine)  WITH_OCR_ENGINE=false; shift;;
        *)
            echo "internal error: unsupported option" >&2
            exit 119
            ;;
    esac
done
shift                           # past the '--' marker

if test 0 -ne $#; then          # make this look like a `getopt` error
    echo "getopt: too many arguments: '$@'" >&2
    usage 1
fi
test xno != x$SHOW_HELP && usage 0

# There should be exactly one package file in core/

test -d $core
test 1 -eq $(find $core -type f | wc -l)

pkg=$(find $core -type f)
case "$pkg" in
    *.deb)
        install=deb_install
        ;;
    *.rpm)
        install=rpm_install
        ;;
    *)
        echo "internal error: unsupported package format" >&2
        exit 119
        ;;
esac

pkgs="$pkg"

if test -d $data; then
    pkgs="$pkgs $(find $data -type f)"
fi
if test -d $plugins; then
    for pkg in $(find $plugins -type f); do
        case $pkg in
            *-network*)
                $($WITH_NETWORK) && pkgs="$pkgs $pkg"
                ;;
            *-ocr-engine*)
                $($WITH_OCR_ENGINE) && pkgs="$pkgs $pkg"
                ;;
            *)
                pkgs="$pkgs $pkg"
                ;;
        esac
    done
fi

if [ -e $base/DefaultSettings.SF2 ]; then
  mkdir $HOME/.epsonscan2/
  cp $base/DefaultSettings.SF2 $HOME/.epsonscan2/
fi


$install $pkgs

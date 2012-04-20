
# Health Resource Tracker

This app tracks resource flows in the health sector from their many sources to the ultimate health function they serve. Information about health spending, both planned and realized, are essential for evidence-based budgeting, planning and policy-making.

## Getting Started

### Git config

    #.git/config

    [remote "origin"]
      fetch = +refs/heads/*:refs/remotes/origin/*
      url = git@github.com:siyelo/hrt2.git

    [remote "staging"]
      url = git@heroku.com:hrt-staging.git
      fetch = +refs/heads/*:refs/remotes/staging/*

    [remote "production"]
      url = git@heroku.com:resourcetracking.git
      fetch = +refs/heads/*:refs/remotes/production/*


## License

HRT - Health Resource Tracker
Copyright (C) 2011 USAID

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
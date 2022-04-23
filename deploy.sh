#!/usr/bin/env sh
# abort on errors
set -e
# build
npm run build
# navigate into the build output directory Lxt19990619!
cd dist
# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME
git init
git add -A
git commit -m 'deploy'
git push -f https://github.com/lxt619/Gomoku.git master:gh-pages
cd -
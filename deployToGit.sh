flutter build web --web-renderer auto
cp -R /Users/acorbett/dev/flutter_website_utilities/build/web/ /Users/acorbett/dev/albebaubles.github.io 
cd /Users/acorbett/dev/albebaubles.github.io 
git add .
git commit -am 'deploy' && git push

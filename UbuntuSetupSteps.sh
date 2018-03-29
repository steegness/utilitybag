# Create directory structure
mkdir v1
cd v1
mkdir test
mkdir build
cd build
mkdir js
mkdir static
mkdir styles
mkdir assets
cd ..
mkdir develop
cd develop
mkdir php
mkdir javascript
mkdir less
mkdir assets
mkdir static

# Update and upgrade
# https://stackoverflow.com/questions/33370297/apt-get-update-non-interactive
sudo export DEBIAN_FRONTEND=noninteractive
sudo apt-get update && sudo apt-get -o "Dpkg::Options::=--force-confold" upgrade -q -y --force-yes && sudo apt-get -o "Dpkg::Options::=--force-confold" dist-upgrade -q -y --force-yes
#sudo apt-get update
#sudo apt-get upgrade

# Install node and nmp
sudo apt-get install nodejs
sudo apt-get install npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
sudo chown -R $USER:$(id -gn $USER) /home/cabox/.config
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}
sudo ln -s `which nodejs` /usr/bin/node

# Install npm packages
npm init
sudo npm install --global gulp-cli
sudo npm install gulp gulp-load-plugins gulp-concat jshint gulp-jshint \
            gulp-less gulp-lesshint gulp-print gulp-uglify gulp-uglifycss \
            gulp-rename phplint gulp-phplint gulp-imagemin gulp-rimraf \
            --save-dev --unsafe-perm=true --allow-root

# add .gitignore
touch .gitignore
cat > .gitignore <<EOL
/assets/*
/node_modules/*
/static/*
EOL

# add globalVariables.less since that will be processed first in gulp
# add .lesshintrc
cd less
touch globalVariables.less
touch .lesshintrc
cat > .lesshintrc <<EOL
{
  "idSelector": {
    "enabled": false
  },
  "newlineAfterBlock" : {
    "enabled": false
  },
  "propertyOrdering": {
    "enabled": false
  }
}
EOL
cd ..

# set up gulpfile.js
touch gulpfile.js
cat > gulpfile.js <<EOL
var gulp = require('gulp');
var plugins = require('gulp-load-plugins')();
var path = require('path');
var p = require('./package.json')
//gulp-concat, gulp-jshint, gulp-less, gulp-uglify (js), gulp-uglifycss, jshint, phplint
//gulp-imagemin, gulp-load-plugins, gulp-print, gulp-lesshint, gulp-rimraf

var project = p.name;
var src = '';
var build = '../build/';

// JS Lint Task
gulp.task('jslint', function() {
    return gulp.src(src + 'javascript/*.js')
        .pipe(plugins.print())
        .pipe(plugins.jshint())
        .pipe(plugins.jshint.reporter('default'));
});

// PHP Lint Task
gulp.task('phplint', function() {
    return gulp.src(src + 'php/**/*.php')
        .pipe(plugins.print())
        .pipe(plugins.phplint())
        .pipe(plugins.phplint.reporter('default'));
});

// LESS Lint Task
gulp.task('lesslint', function() {
    return gulp.src([src + 'less/global*.less', src + 'less/*.less'])
        .pipe(plugins.print())
        .pipe(plugins.lesshint(
          {configPath: src + 'less/.lesshintrc'}
        ))
        .pipe(plugins.lesshint.reporter());
});

// Optimize the images
gulp.task('imageopt', function() {
    return gulp.src(src + 'assets/*.{png,gif,jpg}')
        .pipe(plugins.print())
        .pipe(plugins.imagemin())
        .pipe(gulp.dest(build + 'assets'));
});

gulp.task('clean-less', function() {
  return gulp.src(build + 'styles/*')
    .pipe(plugins.rimraf( {force: true} ))
});

gulp.task('clean-js', function() {
  return gulp.src(build + 'js/*')
    .pipe(plugins.rimraf( {force: true} ))
});

gulp.task('clean-php', function() {
  return gulp.src(build + '/*.php')
    .pipe(plugins.rimraf( {force: true} ))
});

// Compile Our Less and move to build
gulp.task('less', ['clean-less'], function() {
    return gulp.src([src + 'less/globalVariables.less', src + 'less/*.less'])
        //.pipe(plugins.less())
        .pipe(plugins.print())
        .pipe(plugins.concat(project + '.less'))
        .pipe(plugins.less())
        //.pipe(plugins.less({
        //  paths: [ path.join(__dirname, 'less') ]
        //}))
        .pipe(gulp.dest(build + 'styles'));
});

// Concatenate & Minify JS and move to build
gulp.task('scripts', ['clean-js'], function() {
    return gulp.src(src + 'javascript/*.js')
        .pipe(plugins.print())
        .pipe(plugins.concat(project + '.js'))
        .pipe(gulp.dest(build + 'js'))
        .pipe(plugins.rename(project + '.min.js'))
        .pipe(plugins.uglify())
        .pipe(gulp.dest(build + 'js'));
});

// Move php to build
gulp.task('phpmove', ['clean-php'], function() {
    return gulp.src(src + 'php/**/*.php')
        .pipe(plugins.print())
        .pipe(gulp.dest(build));
});

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch(src + 'javascript/*.js', ['jslint', 'scripts']);
    gulp.watch(src + 'less/*.less', ['lesslint', 'less']);
    gulp.watch(src + 'php/**/*.php', ['phplint', 'phpmove']);
    gulp.watch(src + 'assets/*.jpg', ['imageopt']);
});

gulp.task('default', ['imageopt', 'jslint', 'scripts', 'lesslint', 'less', 'phplint', 'phpmove', 'watch']);
EOL

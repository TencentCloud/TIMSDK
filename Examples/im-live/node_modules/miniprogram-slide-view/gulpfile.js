const gulp = require('gulp');
const clean = require('gulp-clean');

const config = require('./tools/config');
const BuildTask = require('./tools/build');
const id = require('./package.json').name || 'miniprogram-custom-component';

// build task instance
new BuildTask(id, config.entry);

// clean the generated folders and files
gulp.task('clean', gulp.series(() => {
    return gulp.src(config.distPath, { read: false, allowEmpty: true })
        .pipe(clean())
}, done => {
    if (config.isDev) {
        return gulp.src(config.demoDist, { read: false, allowEmpty: true })
            .pipe(clean());
    }

    done();
}));
// watch files and build
gulp.task('watch', gulp.series(`${id}-watch`));
// build for develop
gulp.task('dev', gulp.series(`${id}-dev`));
// build for publish
gulp.task('default', gulp.series(`${id}-default`));

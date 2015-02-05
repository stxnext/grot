'use strict';

module.exports = function (grunt) {
    var config = {
        src: 'src',
        build: 'build',
        tmp: '.tmp'
    };

    grunt.initConfig({
        app: config,
        pkg: grunt.file.readJSON('package.json'),
        watch: {
            options: {
                spawn: false
            },
            coffee: {
                files: ['<%= app.src %>/coffeescript/{,*/}*.coffee'],
                tasks: ['coffee']
            },
            statics: {
                files: [
                    '<%= app.src %>/html/{,*/}*.html',
                    '<%= app.src %>/javascript/{,*/}*.js',
                    '<%= app.src %>/css/{,*/}*.css'
                ],
                tasks: ['copy:dev']
            }
        },
        connect: {
            options: {
                port: 8080,
                open: true,
                //livereload: 35729,
                hostname: '0.0.0.0'
            },
            livereload: {
                options: {
                    middleware: function (connect) {
                        return [
                            connect.static(config.tmp),
                            connect().use('/img', connect.static(config.src + '/images'))
                        ];
                    }
                }
            }
        },
        clean: {
            build: ['<%= app.tmp %>', '<%= app.build %>'],
            dev: '<%= app.tmp %>'
        },
        coffee: {
            build: {
                files: [{
                    expand: true,
                    cwd: '<%= app.src %>/coffeescript',
                    src: '*.coffee',
                    dest: '<%= app.tmp %>/js',
                    ext: '.js'
                }]
            }
        },
        uglify: {
            build: {
                files: {
                    '<%= app.build %>/js/grot.min.js': [
                        '<%= app.tmp %>/js/{,*/}*.js'
                    ]
                }
            }
        },
        useminPrepare: {
            html: '<%= app.tmp %>/index.html',
            options: {
                dest: '<%= app.build %>'
            }
        },
        usemin: {
            html: ['<%= app.build %>/index.html'],
            options: {
                assetsDirs: ['<%= app.build %>']
            }
        },
        concat: {},
        copy: {
            dev: {
                files: [{
                    expand: true,
                    dot: true,
                    cwd: '<%= app.src %>/javascript',
                    dest: '<%= app.tmp %>/js/',
                    src: [
                        '{,*/}*.js',
                    ]
                },{
                    expand: true,
                    dot: true,
                    cwd: '<%= app.src %>/fonts',
                    dest: '<%= app.tmp %>/fonts/',
                    src: [
                        '*',
                    ]
                },{
                    expand: true,
                    dot: true,
                    cwd: '<%= app.src %>/css',
                    dest: '<%= app.tmp %>/css/',
                    src: [
                        '*',
                    ]
                },{
                    expand: true,
                    dot: true,
                    cwd: '<%= app.src %>/html',
                    src: '*.html',
                    dest: '<%= app.tmp %>'
                }]
            },
            build: {
                files: [{
                    expand: true,
                    dot: true,
                    flatten: true,
                    cwd: '<%= app.src %>',
                    dest: '<%= app.build %>/img',
                    src: [
                        '{,*/}*.{png,jpg,jpeg}',
                    ]
                },{
                    expand: true,
                    dot: true,
                    cwd: '<%= app.src %>/fonts',
                    dest: '<%= app.build %>/fonts/',
                    src: [
                        '*',
                    ]
                },{
                    expand: true,
                    dot: true,
                    cwd: '<%= app.src %>/html',
                    src: '*.html',
                    dest: '<%= app.build %>'
                }]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-usemin');

    grunt.registerTask('dev', [
        'clean:dev',
        'copy:dev',
        'coffee',
        'connect:livereload',
        'watch'
    ]);

    grunt.registerTask('build', [
        'clean',
        'copy',
        'coffee',
        'useminPrepare',
        'concat',
        'uglify',
        'usemin'
    ]);

    grunt.registerTask('default', [
        'build'
    ]);
};

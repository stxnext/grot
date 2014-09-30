class Grot.MenuWidget extends GrotEngine.Widget
    # Menu widget

    group: null
    menuLayer: null
    game: null

    constructor: (config) ->
        super

        @background = new Kinetic.Rect
            width: 1700
            height: 900
            x: 0
            y: 0
            fill: cfg.gameOverMessageColor
            opacity: 0.75

        @gameName = new Kinetic.Text
            x: 785
            y: 100
            text: 'Grot'
            align: 'center'
            fontSize: 60
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        @line = new Kinetic.Rect
            x: 550
            y: 200
            width: 600
            height: 2
            fill: cfg.fontMenuColor

        resetGameImageObj = new Image()
        @resetGameImg = new Kinetic.Image
            x: 685
            y: 300
            image: resetGameImageObj
            width: 75
            height: 75

        @resetGameText = new Kinetic.Text
            x: 660
            y: 400
            text: 'New Game'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        scoreBoardImageObj = new Image()
        @scoreBoardLinkImg = new Kinetic.Image
            x: 960
            y: 300
            image: scoreBoardImageObj
            width: 75
            height: 75

        @scoreBoardLinkText = new Kinetic.Text
            x: 935
            y: 400
            text: 'High scores'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        aboutImageObj = new Image()
        @aboutImg = new Kinetic.Image
            x: 685
            y: 550
            image: aboutImageObj
            width: 75
            height: 75

        @aboutText = new Kinetic.Text
            x: 685
            y: 650
            text: 'About'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        resumeImageObj = new Image()
        @resumeImg = new Kinetic.Image
            x: 960
            y: 550
            image: resumeImageObj
            width: 75
            height: 75

        @resumeText = new Kinetic.Text
            x: 960
            y: 650
            text: 'Resume'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor


        resetGameImageObj.src = 'img/menu-new-game-icon.png'
        scoreBoardImageObj.src = 'img/menu-high-score-icon.png'
        aboutImageObj.src = 'img/menu-about-icon.png'
        resumeImageObj.src = 'img/menu-resume-icon.png'

        @resetGameImg.on 'mousedown touchstart', (event) =>
            window.location.replace(window.location.href)

        @resetGameText.on 'mousedown touchstart', (event) =>
            window.location.replace(window.location.href)

        @scoreBoardLinkImg.on 'mousedown touchstart', (event) =>
            window.location.replace(cfg.scoreBoardLink)

        @scoreBoardLinkText.on 'mousedown touchstart', (event) =>
            window.location.replace(cfg.scoreBoardLink)

        @aboutImg.on 'mousedown touchstart', (event) =>
            game.renderManager.menuOverlay.helpWidget.draw()

        @aboutText.on 'mousedown touchstart', (event) =>
            game.renderManager.menuOverlay.helpWidget.draw()

        @resumeImg.on 'mousedown touchstart', (event) =>
            @removeLay()

        @resumeText.on 'mousedown touchstart', (event) =>
            @removeLay()

        @on 'eventMenuDraw', @draw

    removeLay: () =>
        @removeChildren()
        @getLayer().draw()

    draw: () =>
        @add @background
        @add @gameName
        @add @line
        @add @resetGameImg
        @add @resetGameText
        @add @scoreBoardLinkImg
        @add @scoreBoardLinkText
        @add @aboutImg
        @add @aboutText
        @add @resumeImg
        @add @resumeText
        @getLayer().draw()

class Grot.GameOverWidget extends GrotEngine.Widget
    # Game over widget

    game: null

    constructor: (config) ->
        super

        @background = new Kinetic.Rect
            width: 1700
            height: 900
            x: 0
            y: 0
            fill: cfg.gameOverMessageColor
            opacity: 0.75

        @line = new Kinetic.Rect
            x: 550
            y: 200
            width: 600
            height: 2
            fill: cfg.fontMenuColor

        @gameOverMsg = new Kinetic.Text
            x: 850
            y: 125
            text: 'Game Over'
            align: 'center'
            fontSize: 60
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        @yourScoreMsg = new Kinetic.Text
            x: 875
            y: 300
            text: 'Your Score:'
            align: 'center'
            fontSize: 40
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        @scoreResult = new Kinetic.Text
            x: 850
            y: 350
            text: ''
            align: 'center'
            fontSize: 35
            fontfamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: '#00BFFF'

        resetGameImageObj = new Image()
        @resetGameImg = new Kinetic.Image
            x: 685
            y: 500
            image: resetGameImageObj
            width: 75
            height: 75

        @resetGameText = new Kinetic.Text
            x: 725
            y: 600
            text: 'New Game'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        scoreBoardImageObj = new Image()
        @scoreBoardLinkImg = new Kinetic.Image
            x: 960
            y: 500
            image: scoreBoardImageObj
            width: 75
            height: 75

        @scoreBoardLinkText = new Kinetic.Text
            x: 1000
            y: 600
            text: 'High scores'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        resetGameImageObj.src = 'img/menu-new-game-icon.png'
        scoreBoardImageObj.src = 'img/menu-high-score-icon.png'

        @resetGameImg.on 'mousedown touchstart', (event) =>
            window.location.replace(window.location.href)

        @resetGameText.on 'mousedown touchstart', (event) =>
            window.location.replace(window.location.href)

        @scoreBoardLinkImg.on 'mousedown touchstart', (event) =>
            window.location.replace(cfg.scoreBoardLink)

        @scoreBoardLinkText.on 'mousedown touchstart', (event) =>
            window.location.replace(cfg.scoreBoardLink)

        @centerElement(@gameOverMsg)
        @centerElement(@yourScoreMsg)
        @centerElement(@resetGameText)
        @centerElement(@scoreBoardLinkText)

        @on 'eventGameOverDraw', @draw

    draw: () =>
        @add @background
        @add @gameOverMsg
        @add @line
        @add @yourScoreMsg
        @add @scoreResult
        @add @resetGameImg
        @add @resetGameText
        @add @scoreBoardLinkImg
        @add @scoreBoardLinkText
        @getLayer().draw()

    update: (result) ->
        # update result for game over message
        @scoreResult.setText(result)
        @centerElement(@scoreResult)

class Grot.HelpWidget extends GrotEngine.Widget
    # Game over widget

    game: null

    constructor: (config) ->
        super

        @background = new Kinetic.Rect
            width: 1700
            height: 900
            x: 0
            y: 0
            fill: cfg.gameOverMessageColor
            opacity: 0.75

        @appName = new Kinetic.Text
            x: 850
            y: 50
            fontSize: 80
            fontFamily: cfg.fontFamily
            text: 'GROT'
            fill: cfg.fontMenuColor

        @engAppName = @appName.clone
            y: 100
            fontSize: 40
            text: '(eng. Arrowhead)'

        @description = @appName.clone
            y: 350
            fontSize: 30
            text: cfg.helpDesc

        @points = @appName.clone
            y: 625
            fontSize: 30
            text: 'Points'

        @circle1 = new Kinetic.Circle
            x: 575
            y: 700
            radius: 40
            fill: cfg.circleColor1

        @circlePoints1 = new Kinetic.Text
            x: 625
            y: 685
            text: 'x1'
            fill: cfg.fontMenuColor
            fontSize: 30
            fontFamily: cfg.fontFamily

        @circle2 = @circle1.clone
            x: 750
            fill: cfg.circleColor2

        @circlePoints2 = @circlePoints1.clone
            x: 800
            text: 'x2'

        @circle3 = @circle1.clone
            x: 925
            fill: cfg.circleColor3

        @circlePoints3 = @circlePoints1.clone
            x: 975
            text: 'x3'

        @circle4 = @circle1.clone
            x: 1100
            fill: cfg.circleColor4

        @circlePoints4 = @circlePoints1.clone
            x: 1150
            text: 'x4'

        resumeImageObj = new Image()
        @resumeImg = new Kinetic.Image
            x: 850
            y: 815
            image: resumeImageObj
            width: 75
            height: 75

        @resumeText = new Kinetic.Text
            x: 850
            y: 875
            text: 'Resume'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        resumeImageObj.src = 'img/menu-resume-icon.png'

        @resumeImg.on 'mousedown touchstart', (event) =>
            @removeLay()

        @resumeText.on 'mousedown touchstart', (event) =>
            @removeLay()

        @on 'eventMenuDraw', @draw

        @centerElement(@appName)
        @centerElement(@engAppName)
        @centerElement(@description)
        @centerElement(@points)
        @centerElement(@resumeImg)
        @centerElement(@resumeText)

    draw: () =>
        @add @background
        @add @appName
        @add @engAppName
        @add @description
        @add @points
        @add @circle1
        @add @circlePoints1
        @add @circle2
        @add @circlePoints2
        @add @circle3
        @add @circlePoints3
        @add @circle4
        @add @circlePoints4
        @add @resumeImg
        @add @resumeText
        @getLayer().draw()

    removeLay: () =>
        @removeChildren()
        @getLayer().draw()

class Grot.MenuOverlay extends GrotEngine.Layer
    # Menu, GameOver, Help widgets

    constructor: ->
        super

        @gameOverWidget = new Grot.GameOverWidget
        @add @gameOverWidget

        @menuWidget = new Grot.MenuWidget
        @add @menuWidget

        @helpWidget = new Grot.HelpWidget
        @add @helpWidget

    gameOverWidgetDraw: () ->
        @gameOverWidget.fire 'eventGameOverDraw'

    menuWidgetDraw: () ->
        @menuWidget.fire 'eventMenuDraw'

    helpWidgetDraw: () ->
        @helpWidget.fire 'eventHelpDraw'

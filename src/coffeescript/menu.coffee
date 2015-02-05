class Grot.MenuWidget extends GrotEngine.Widget
    # Menu widget

    group: null
    menuLayer: null
    showPreview: false
    game: null

    constructor: (config) ->
        super

        previewHeight = if @showPreview then cfg.previewHeight else 0
        @background = new Kinetic.Rect
            width: 600
            height: 900+previewHeight
            x: 0
            y: 0
            fill: cfg.overlayColor
            opacity: 0.9

        @container = new GrotEngine.Widget
            width: 600
            height: 900+previewHeight
            margins: {x: 0, y: 0}
            layer: @menuLayer

        @gameName = new Kinetic.Text
            x: 235
            y: 100
            text: 'GROT'
            align: 'center'
            fontSize: 60
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        @line = new Kinetic.Rect
            x: 0
            y: 200
            width: 600
            height: 2
            fill: cfg.fontMenuColor

        resetGameImageObj = new Image()
        @resetGameImg = new Kinetic.Image
            x: 125
            y: 300
            image: resetGameImageObj
            width: 75
            height: 75

        @resetGameText = new Kinetic.Text
            x: 100
            y: 400
            text: 'New Game'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        scoreBoardImageObj = new Image()
        @scoreBoardLinkImg = new Kinetic.Image
            x: 410
            y: 300
            image: scoreBoardImageObj
            width: 75
            height: 75

        @scoreBoardLinkText = new Kinetic.Text
            x: 385
            y: 400
            text: 'High scores'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        helpImageObj = new Image()
        @helpImage = new Kinetic.Image
            x: 125
            y: 550
            image: helpImageObj
            width: 75
            height: 75

        @helpText = new Kinetic.Text
            x: 134
            y: 650
            text: 'Help'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        aboutImageObj = new Image()
        @aboutImg = new Kinetic.Image
            x: 410
            y: 550
            image: aboutImageObj
            width: 75
            height: 75

        @aboutText = new Kinetic.Text
            x: 412
            y: 650
            text: 'About'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        resumeImageObj = new Image()
        @resumeImg = new Kinetic.Image
            x: 265
            y: 740
            image: resumeImageObj
            width: 75
            height: 75

        @resumeText = new Kinetic.Text
            x: 258
            y: 820
            text: 'Resume'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        resetGameImageObj.src = 'img/menu-new-game-icon.png'
        scoreBoardImageObj.src = 'img/menu-high-score-icon.png'
        helpImageObj.src = 'img/menu-help-icon.png'
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

        @helpImage.on 'mousedown touchstart', (event) =>
            @fire 'menuRemove'
            @menuLayer.fire 'showHelp'

        @helpText.on 'mousedown touchstart', (event) =>
            @fire 'menuRemove'
            @menuLayer.fire 'showHelp'

        @aboutImg.on 'mousedown touchstart', (event) =>
            @fire 'menuRemove'
            @menuLayer.fire 'showAbout'

        @aboutText.on 'mousedown touchstart', (event) =>
            @fire 'menuRemove'
            @menuLayer.fire 'showAbout'

        @resumeImg.on 'mousedown touchstart', @close

        @resumeText.on 'mousedown touchstart', @close

        @on 'menuDraw', @draw
        @on 'menuRemove', @close
        @fire 'update'

    updateHandler: ->
        if @menuLayer.parent
            @container.fire 'update'

    draw: () =>
        @add @background
        @add @container
        @container.add @gameName
        @container.add @line
        @container.add @resetGameImg
        @container.add @resetGameText
        @container.add @scoreBoardLinkImg
        @container.add @scoreBoardLinkText
        @container.add @helpImage
        @container.add @helpText
        @container.add @aboutImg
        @container.add @aboutText
        @container.add @resumeImg
        @container.add @resumeText
        @getLayer().draw()

    close: () =>
        @removeChildren()
        @menuLayer.fire 'closeMenuOverlay'


class Grot.GameOverWidget extends GrotEngine.Widget
    # Game over widget

    game: null
    menuLayer: null
    showPreview: null

    constructor: (config) ->
        super

        previewHeight = if @showPreview then cfg.previewHeight else 0
        @background = new Kinetic.Rect
            width: 600
            height: 900+previewHeight
            x: 0
            y: 0
            fill: cfg.overlayColor
            opacity: 0.9

        @container = new GrotEngine.Widget
            width: 600
            height: 900+previewHeight
            margins: {x: 0, y: 0}
            layer: @menuLayer

        @line = new Kinetic.Rect
            x: 0
            y: 200
            width: 600
            height: 2
            fill: cfg.fontMenuColor

        @gameOverMsg = new Kinetic.Text
            x: 320
            y: 125
            text: 'Game Over'
            align: 'center'
            fontSize: 60
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        @yourScoreMsg = new Kinetic.Text
            x: 315
            y: 300
            text: 'Your Score:'
            align: 'center'
            fontSize: 40
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        @scoreResult = new Kinetic.Text
            x: 300
            y: 350
            text: ''
            align: 'center'
            fontSize: 35
            fontfamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: '#00BFFF'

        resetGameImageObj = new Image()
        @resetGameImg = new Kinetic.Image
            x: 135
            y: 500
            image: resetGameImageObj
            width: 75
            height: 75

        @resetGameText = new Kinetic.Text
            x: 180
            y: 610
            text: 'New Game'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        scoreBoardImageObj = new Image()
        @scoreBoardLinkImg = new Kinetic.Image
            x: 410
            y: 500
            image: scoreBoardImageObj
            width: 75
            height: 75

        @scoreBoardLinkText = new Kinetic.Text
            x: 455
            y: 610
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

        @on 'gameOverDraw', @draw
        @on 'gameOverRemove', @close

    updateHandler: ->
        if @menuLayer.parent
            @container.fire 'update'

    draw: (score) =>
        @scoreResult.setText(score)
        @centerElement(@scoreResult)
        @add @background
        @add @container
        @container.add @gameOverMsg
        @container.add @line
        @container.add @yourScoreMsg
        @container.add @scoreResult
        @container.add @resetGameImg
        @container.add @resetGameText
        @container.add @scoreBoardLinkImg
        @container.add @scoreBoardLinkText
        @getLayer().draw()

    close: () =>
        @removeChildren()
        @menuLayer.fire 'closeMenuOverlay'


class Grot.HelpWidget extends GrotEngine.Widget
    # help widget

    game: null
    menuLayer: null
    showPreview: false

    constructor: (config) ->
        super

        previewHeight = if @showPreview then cfg.previewHeight else 0
        console.log previewHeight
        @background = new Kinetic.Rect
            width: 600
            height: 900+previewHeight
            x: 0
            y: 0
            fill: cfg.overlayColor
            opacity: 0.9

        @container = new GrotEngine.Widget
            width: 600
            height: 900+previewHeight
            margins: {x: 0, y: 0}
            layer: @menuLayer

        @appName = new Kinetic.Text
            x: 10
            y: 50
            fontSize: 60
            fontFamily: cfg.fontFamily
            text: 'GROT'
            fill: cfg.fontMenuColor

        @engAppName = @appName.clone
            y: 110
            x: 10
            fontSize: 36
            text: '(eng. Arrowhead)'

        @description = @appName.clone
            y: 180
            x: 10
            width: 580
            fontSize: 26
            text: cfg.helpDesc

        @points = @appName.clone
            y: 550
            x: 25
            fontSize: 30
            text: 'Points:'

        @pointsVisualisation = new GrotEngine.Widget
            width: 580
            height: 42
            x: 10
            y: 600

        @circle1 = new Kinetic.Circle
            x: 50
            y: 50
            radius: 40
            fill: cfg.circleColor1

        @circlePoints1 = new Kinetic.Text
            x: 100
            y: 35
            text: 'x1'
            fill: cfg.fontMenuColor
            fontSize: 30
            fontFamily: cfg.fontFamily

        @circle2 = @circle1.clone
            x: 190
            fill: cfg.circleColor2

        @circlePoints2 = @circlePoints1.clone
            x: 240
            text: 'x2'

        @circle3 = @circle1.clone
            x: 330
            fill: cfg.circleColor3

        @circlePoints3 = @circlePoints1.clone
            x: 380
            text: 'x3'

        @circle4 = @circle1.clone
            x: 470
            fill: cfg.circleColor4

        @circlePoints4 = @circlePoints1.clone
            x: 520
            text: 'x4'

        resumeImageObj = new Image()
        @resumeImg = new Kinetic.Image
            x: 265
            y: 740
            image: resumeImageObj
            width: 75
            height: 75

        @resumeText = new Kinetic.Text
            x: 258
            y: 820
            text: 'Resume'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        resumeImageObj.src = 'img/menu-resume-icon.png'

        @resumeImg.on 'mousedown touchstart', @close
        @resumeText.on 'mousedown touchstart', @close

        @on 'helpDraw', @draw
        @on 'helpRemove', @close
        @fire 'update'

    updateHandler: ->
        if @menuLayer.parent
            @container.fire 'update'

    draw: () =>
        @add @background
        @add @container
        @container.add @appName
        @container.add @engAppName
        @container.add @description
        @container.add @points
        @container.add @pointsVisualisation
        @pointsVisualisation.add @circle1
        @pointsVisualisation.add @circlePoints1
        @pointsVisualisation.add @circle2
        @pointsVisualisation.add @circlePoints2
        @pointsVisualisation.add @circle3
        @pointsVisualisation.add @circlePoints3
        @pointsVisualisation.add @circle4
        @pointsVisualisation.add @circlePoints4
        @container.add @resumeImg
        @container.add @resumeText
        @getLayer().draw()

    close: () =>
        @removeChildren()
        @menuLayer.fire 'closeMenuOverlay'


class Grot.AboutWidget extends GrotEngine.Widget
    # about widget

    game: null
    menuLayer: null
    showPreview: false

    constructor: (config) ->
        super

        previewHeight = if @showPreview then cfg.previewHeight else 0
        @background = new Kinetic.Rect
            width: 600
            height: 900+previewHeight
            x: 0
            y: 0
            fill: cfg.overlayColor
            opacity: 0.9

        @container = new GrotEngine.Widget
            width: 600
            height: 900+previewHeight
            margins: {x: 0, y: 0}
            layer: @menuLayer

        @appName = new Kinetic.Text
            x: 10
            y: 50
            fontSize: 60
            fontFamily: cfg.fontFamily
            text: 'GROT'
            fill: cfg.fontMenuColor

        @appVer = @appName.clone
            y: 110
            x: 10
            fontSize: 36
            text: cfg.aboutVer

        @description = @appName.clone
            y: 180
            x: 10
            width: 580
            fontSize: 26
            text: cfg.aboutDesc

        logoImageObj = new Image()
        @logoImg = new Kinetic.Image
            x: 15
            y: 245
            image: logoImageObj
            width: 182
            height: 182

        resumeImageObj = new Image()
        @resumeImg = new Kinetic.Image
            x: 265
            y: 740
            image: resumeImageObj
            width: 75
            height: 75

        @resumeText = new Kinetic.Text
            x: 258
            y: 820
            text: 'Resume'
            align: 'center'
            fontSize: 25
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontMenuColor

        logoImageObj.src = 'img/stxnext-logo.png'
        resumeImageObj.src = 'img/menu-resume-icon.png'

        @logoImg.on 'mousedown touchstart', (event) =>
            window.location.replace(cfg.stxnextLink)
        @resumeImg.on 'mousedown touchstart', @close
        @resumeText.on 'mousedown touchstart', @close

        @on 'aboutDraw', @draw
        @on 'aboutRemove', @close
        @fire 'update'

    updateHandler: ->
        if @menuLayer.parent
            @container.fire 'update'

    draw: () =>
        @add @background
        @add @container
        @container.add @appName
        @container.add @appVer
        @container.add @description
        @container.add @logoImg
        @container.add @resumeImg
        @container.add @resumeText
        @getLayer().draw()

    close: () =>
        @removeChildren()
        @menuLayer.fire 'closeMenuOverlay'


class Grot.MenuOverlay extends GrotEngine.Layer
    # Menu, GameOver, Help, About widgets

    showPreview: false
    renderManager: null

    constructor: ->
        super

        @gameOverWidget = new Grot.GameOverWidget
            menuLayer: @
            showPreview: @showPreview

        @menuWidget = new Grot.MenuWidget
            menuLayer: @
            showPreview: @showPreview

        @helpWidget = new Grot.HelpWidget
            menuLayer: @
            showPreview: @showPreview

        @aboutWidget = new Grot.AboutWidget
            menuLayer: @
            showPreview: @showPreview

        @on 'showGameOver', @gameOverWidgetDraw
        @on 'showMenu', @menuWidgetDraw
        @on 'showHelp', @helpWidgetDraw
        @on 'showAbout', @aboutWidgetDraw
        @on 'closeMenuOverlay', @closeMenuOverlay
        @on 'onOverlayOpen', @onOverlayOpen

    closeMenuOverlay: ->
        @renderManager.stage.fire 'normalizeBoardStuff'
        document.body.style.backgroundColor = cfg.bodyColor
        @removeChildren
        @draw()

    onOverlayOpen: ->
        @renderManager.stage.fire 'blurBoardStuff'
        document.body.style.backgroundColor = cfg.overlayBodyColor

    updateHandler: ->
        super
        @gameOverWidget.fire 'update'
        @menuWidget.fire 'update'
        @helpWidget.fire 'update'
        @aboutWidget.fire 'update'

    gameOverWidgetDraw: (score) ->
        @fire 'onOverlayOpen'
        @add @gameOverWidget
        @gameOverWidget.fire 'gameOverDraw', score

    menuWidgetDraw: () ->
        @fire 'onOverlayOpen'
        @add @menuWidget
        @menuWidget.fire 'menuDraw'

    helpWidgetDraw: () ->
        @fire 'onOverlayOpen'
        @add @helpWidget
        @helpWidget.fire 'helpDraw'

    aboutWidgetDraw: () ->
        @fire 'onOverlayOpen'
        @add @aboutWidget
        @aboutWidget.fire 'aboutDraw'

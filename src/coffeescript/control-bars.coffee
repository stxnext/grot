TWEEN_DURATION = cfg.tweenDuration

class Grot.TopBarWidget extends GrotEngine.Widget
    # Top bar which displays current game stats

    game: null
    scoreLabel: null
    score: null
    movesLabel: null
    moves: null
    showPreview: false

    constructor: (config) ->
        super

        @background = new Kinetic.Rect
            width: 600
            height: 180
            fill: cfg.bodyColor
        @add @background

        @scoreLabel = new Kinetic.Text
            x: 155
            y: 50
            text: 'Score'
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontScoMovColor

        @score = new Kinetic.Text
            x: 150
            y: 100
            text: @game.score
            align: 'center'
            fontSize: cfg.fontScoMovSize
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontScoMovNumColor

        @scoreDiff = new Kinetic.Text
            x: 150
            y: 150
            text: ''
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontScoMovNumColor

        @movesLabel = new Kinetic.Text
            x: 455
            y: 50
            text: 'Moves'
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontScoMovColor

        @moves = new Kinetic.Text
            x: 450
            y: 100
            text: @game.moves
            align: 'center'
            fontSize: cfg.fontScoMovSize
            fontFamily: cfg.fontFamily
            fontStyle: cfg.fontStyle
            fill: cfg.fontScoMovNumColor

        @movesDiff = new Kinetic.Text
            x: 450
            y: 150
            text: ''
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontScoMovNumColor

        line = new Kinetic.Rect
            x: 0
            y: 180
            width: 600
            height: 2
            fill: cfg.fontScoMovNumColor

        @centerElement(@scoreLabel)
        @centerElement(@score)
        @centerElement(@scoreDiff)
        @centerElement(@movesLabel)
        @centerElement(@moves)
        @centerElement(@movesDiff)

        @add @scoreLabel
        @add @score
        @add @scoreDiff
        @add @movesLabel
        @add @moves
        @add @movesDiff
        @add line

    delayAnim: (diff) =>
        delay1s =>
            tween = new Kinetic.Tween
                node: diff
                opacity: 0
                duration: TWEEN_DURATION
                onFinish: ->
                    @destroy()

            tween.play()

    update: () ->
        # update game stats
        @score.setText(@game.score)
        if @game.scoreDiff == 0
            @scoreDiff.setText(' ')
        else
            # if new value of scoreDiff than show it and after that fade it out
            @scoreDiff.setText('+'+@game.scoreDiff)
            @scoreDiff.opacity(1)
            @delayAnim @scoreDiff

        @moves.setText(@game.moves)
        if @game.movesDiff == 0
            @movesDiff.setText(' ')
        else
            # if new value of movesDiff than show it and after that fade it out
            @movesDiff.setText('+'+@game.movesDiff)
            @movesDiff.opacity(1)
            @delayAnim @movesDiff

        @centerElement(@score)
        @centerElement(@scoreDiff)
        @centerElement(@moves)
        @centerElement(@movesDiff)
        @getLayer().draw()


class Grot.BottomBarWidget extends GrotEngine.Widget
    # Bottom bar which displays help button

    label: null
    game: null
    help: null
    menu: null
    showPreview: false

    constructor: (config) ->
        super

        previewHeight = if @showPreview then cfg.previewHeight else 0
        @background = new Kinetic.Rect
            width: 600
            height: 120
            x: 0
            y: 780+previewHeight
            fill: cfg.bodyColor
        @add @background

        # group for help button
        @buttonHelpGroup = new Kinetic.Group
            x: 524
            y: 820+previewHeight

        @circleHelp = new Kinetic.Circle
            x: 20
            y: 30
            radius: 40
            fill: cfg.circleColor4

        @buttonHelpGroup.add @circleHelp

        # help layer
        imageQuestionMarkObj = new Image()
        imageQuestionMarkObj.onload = () =>
            @imageQuestionMarkHelpLink = new Kinetic.Image
                x: 2
                y: 6
                image: imageQuestionMarkObj
                width: 40
                height: 56

            @buttonHelpGroup.add @imageQuestionMarkHelpLink
            @add @buttonHelpGroup

        imageQuestionMarkObj.src = 'img/question-mark-icon.png'

        @buttonHelpGroup.on 'mousedown touchstart', (event) =>
            game.renderManager.menuOverlay.fire 'showHelp'

        heroImgObj = new Image()
        heroImgObj.onload = () =>
            @hero = new Kinetic.Image
                x: 210
                y: 746+previewHeight
                image: heroImgObj
                width: 180
                height: 150

            @add @hero
            @getLayer().draw()

        heroImgObj.src = 'img/hero.png'

        # group for menu button
        @buttonMenuGroup = new Kinetic.Group
            x: 36
            y: 820+previewHeight

        @circleMenu = new Kinetic.Circle
            x: 20
            y: 30
            radius: 40
            fill: cfg.circleColor4

        @rectMenu1 = new Kinetic.Rect
            x: 5
            y: 10
            width: 10
            height: 40
            fill: cfg.fontMenuColor

        @rectMenu2 = @rectMenu1.clone
            x: 25

        @buttonMenuGroup.add @circleMenu
        @buttonMenuGroup.add @rectMenu1
        @buttonMenuGroup.add @rectMenu2
        @add @buttonMenuGroup

        @buttonMenuGroup.on 'mousedown touchstart', (event) =>
            game.renderManager.menuOverlay.fire 'showMenu'

    centerText: (text) ->
        # place label in center of widget
        text.offsetX(text.width()/2)
        text.offsetY(text.height()/2)

    scale: (scale) ->
        @scale {x: scale, y: scale}
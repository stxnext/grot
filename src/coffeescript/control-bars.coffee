TWEEN_DURATION = cfg.tweenDuration

class Grot.TopBarWidget extends GrotEngine.Widget
    # Top bar which displays current game stats

    game: null
    scoreLabel: null
    score: null
    movesLabel: null
    moves: null

    constructor: (config) ->
        super

        @scoreLabel = new Kinetic.Text
            x: 150
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
            x: 450
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
            y: 200
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

    delay1s: () =>
        tween = new Kinetic.Tween
            node: @scoreDiff
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

            @delay1s()

        @moves.setText(@game.moves)
        if @game.movesDiff == 0
            @movesDiff.setText(' ')
        else
            # if new value of movesDiff than show it and after that fade it out
            @movesDiff.setText('+'+@game.movesDiff)
            @movesDiff.opacity(1)

            @delay1s()

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

    constructor: (config) ->
        super

        # group for help button
        @buttonHelpGroup = new Kinetic.Group
            x: 525
            y: 800

        @circleHelp = new Kinetic.Circle
            x: 20
            y: 20
            radius: 40
            fill: cfg.circleColor4

        @buttonHelpGroup.add @circleHelp

        # help layer
        imageQuestionMarkObj = new Image()
        imageQuestionMarkObj.onload = () =>
            @imageQuestionMarkHelpLink = new Kinetic.Image
                x: 0
                y: 0
                image: imageQuestionMarkObj
                width: 40
                height: 40

            @buttonHelpGroup.add @imageQuestionMarkHelpLink
            @add @buttonHelpGroup

        imageQuestionMarkObj.src = 'img/question-mark-icon.png'

        @buttonHelpGroup.on 'mousedown touchstart', (event) =>
            game.renderManager.menuOverlay.fire 'showHelp'

        heroImgObj = new Image()
        heroImgObj.onload = () =>
            @hero = new Kinetic.Image
                x: 200
                y: 740
                image: heroImgObj
                width: 180
                height: 150

            @add @hero
            @getLayer().draw()

        heroImgObj.src = 'img/hero.png'

        # group for menu button
        @buttonMenuGroup = new Kinetic.Group
            x: 45
            y: 800

        @circleMenu = new Kinetic.Circle
            x: 20
            y: 20
            radius: 40
            fill: cfg.circleColor4

        @rectMenu1 = new Kinetic.Rect
            x: 5
            y: 0
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
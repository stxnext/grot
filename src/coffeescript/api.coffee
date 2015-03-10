class Grot.Api
    board: null
    game: null

    constructor: (@board, @game) ->
        api = @

        @game.renderManager.stage.on 'moveCompleted', (event) ->
            api.sendMoveCompleted()

        @game.renderManager.stage.on 'gameOver', (event) ->
            api.sendGameOver()

    pressArrow: (x, y) ->
        @board.fire 'arrowPress', [x, y]

    sendMoveCompleted: () ->
        if cfg.autoPlay and @game.moves > 0
            @pressArrow Math.floor(Math.random() * @board.size) + 1, Math.floor(Math.random() * @board.size) + 1

    sendGameOver: () ->
        # Currently only non-IE browsers support
        if !!window.dispatchEvent
            window.dispatchEvent(new Event('gameFinished'))

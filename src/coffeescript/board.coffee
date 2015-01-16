class Grot.FieldWidget extends GrotEngine.Widget
    # A cirlcle with label. Circle color depends on field value (points), label shows
    # an arrow. Widget is resized and moved be Renderer.

    circle: null
    label: null
    field: null
    callback: null
    relativeScale: null

    # based on: http://flatuicolors.com/

    colors:
        gray: cfg.circleColor1
        blue: cfg.circleColor2
        green: cfg.circleColor3
        red: cfg.circleColor4

    arrows:
        left: 270
        right: 90
        up: 0
        down: 180
        none: 0

    constructor: (config) ->
        super

        @relativeScale = @field.relativeScale
        @circle = new Kinetic.Circle
            x: 0
            y: 0
            radius: cfg.circleRadius
            fill: @colors[@field.value]
            transformsEnabled: 'position'

        @arrow = arrow.clone()
        @arrow.rotate(@arrows[@field.direction])

        @add @circle
        @add @arrow

        @scale @relativeScale

    relativeMove: (x, y) ->
        # to move widget to absolute position we have to calculate relative position
        # from current position
        @move {x: x - @x(), y: y - @y()}

    reset: () ->
        # update color and arrow after field reset
        @circle.fill(@colors[@field.value])
        angle = @arrows[@field.direction] - @arrow.rotation()
        @arrow.rotate(angle)

    setupCallback: (@callback) ->
        # setup 'onClick'
        widget = @
        @on 'mousedown touchstart', (event) ->
            widget.callback(widget.field, event)


class Grot.Field
    # State of field on a board.

    x: null
    y: null
    id: null
    value: null
    direction: null
    widget: null
    board: null
    renderManager: null
    relativeScale: null
    preview: null

    points:
        gray: 1
        blue: 2
        green: 3
        red: 4

    constructor: (@board, @x, @y) ->
        @id = "#{@x}-#{@y}"
        @renderManager = @board.renderManager
        @relativeScale = @board.fieldRelativeScale
        @preview = @board.preview
        @relativeRadius = 2 * cfg.circleRadius * @relativeScale
        @resetRandoms()
        @widget = new Grot.FieldWidget
            field: @

    resetRandoms: () ->
        nextItem = @preview.pop()
        @value = nextItem['value']
        @direction = nextItem['direction']

        if @widget?
            @widget.reset()

    getPoints: () ->
        # get points of field
        return @points[@value]

    getFieldCenter: ()->
        # calculate positions of a field widget
        relativeRadius = 2 * cfg.circleRadius * @relativeScale
        fieldSpacing = relativeRadius + cfg.spaceBetweenFields * @renderManager.currentScale
        return [@x * fieldSpacing + relativeRadius,  (@y) * fieldSpacing + relativeRadius]

    updatePosition: (@x, @y) ->
        # update field position
        @id = "#{@x}-#{@y}"


class Grot.Preview
    # queue with next fields

    data: []

    constructor: (size) ->
        for x in [0..size*size]
            @data.push(@randomItem())

    randomItem: ->
        # choose random value and random direction
        # most common is gray field, most rare is red one.
        points = [
            'gray', 'gray', 'gray', 'gray',
            'blue', 'blue', 'blue',
            'green', 'green',
            'red'
        ]
        result =
            value: randomChoice(points),
            direction: randomChoice(['left', 'right', 'up', 'down'])
        return result

    pop: ->
        result = @data.shift()
        @data.push @randomItem()
        return result


class Grot.Board extends GrotEngine.Layer
    # Grid of fields.

    size: 9
    fields: []
    preview: null
    fieldRelativeScale: 0
    renderManager: null

    constructor: (config) ->
        super

        @background = new Kinetic.Rect
            width: config.width
            height: config.height
            fill: cfg.bodyColor
        @add @background

        @fieldRelativeScale = 5 / @size
        @createPreview()
        @createBoard()

    createBoard: () ->
        # create size x size board, calculate initial value of fields
        for x in [0..@size-1]
            @fields.push (
                new Grot.Field @, x, y for y in [0..@size-1]
            )

    createPreview: () ->
        @preview = new Grot.Preview @size
        @preview.pop()

    getNextField: (field, lastDirection=null) ->
        # returns next field in chain reaction and information is it last step in this chain reaction
        direction = if lastDirection then lastDirection else field.direction

        if direction == 'left'
            if field.x == 0
                return [field, true]
            nextField = @fields[field.x - 1][field.y]

        else if direction == 'right'
            if field.x == (@size-1)
                return [field, true]
            nextField = @fields[field.x + 1][field.y]

        else if direction == 'up'
            if field.y == 0
                return [field, true]
            nextField = @fields[field.x][field.y - 1]

        else if direction == 'down'
            if field.y == (@size-1)
                return [field, true]
            nextField = @fields[field.x][field.y + 1]

        if nextField.direction == 'none'
            # if next was alread cleared than go further in the same direction
            return @getNextField(nextField, direction)

        return [nextField, false]

    lowerField: (field) ->
        # when chain reaction is over fields that are 'flying' should be lowered
        oldX = field.x
        oldY = field.y
        [nextField, lastMove] = @getNextField(field, 'down')
        newX = nextField.x
        newY = nextField.y

        if not lastMove
            # if not last move, than we have to take one field above
            newY = nextField.y - 1

        if newY == oldY
            # no move
            return []

        # move empty field in old place
        @fields[oldX][oldY] = @fields[newX][newY]
        @fields[oldX][oldY].updatePosition(oldX, oldY)

        # move field to new place
        @fields[newX][newY] = field
        @fields[newX][newY].updatePosition(newX, newY)

        return [newX, newY]
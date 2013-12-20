test "Test rating parser", ()->
    rating_text = """
    All of LVB's rankings at Criticker.com

    100	Battlestar Galactica (2003)
    http://www.criticker.com/film/Battlestar_Galactica_2003/rating/LVB



    88	Borat: Cultural Learnings of America for Make Benefit Glorious Nation of Kazakhstan (2006)	
    http://www.criticker.com/film/Borat_Cultural_Learnings_of_America/rating/LVB

    80	Big (1988)
    http://www.criticker.com/film/Big/rating/LVB

     12  shouldn't be found
     http://www.criticker.com/film/Big/rating/LVB

    44.3  Bogus, but handle it

    0  Zero

    -10  This should get ignored

    100	The Bourne Identity (2002)
    http://www.criticker.com/film/The_Bourne_Identity_2002/rating/LVB
    """

    ratings = parse_ratings(rating_text)
    deepEqual ratings, [100,88,80,44,0,100]

test "Ranges", ()->
    active_config = configs[0]
    ratings = [-1,0,1,9,10,11,20,40,80,89,90,91,99,100,101]
    deepEqual(stratify(ratings, active_config), ([
        ["0-10",4],
        ["11-20",2],
        ["21-30",0],
        ["31-40",1],
        ["41-50",0],
        ["51-60",0],
        ["61-70",0],
        ["71-80",1],
        ["81-90",2],
        ["91-100",3] ]))
    shuf_ratings = _.shuffle(ratings)
    deepEqual(stratify(shuf_ratings, active_config), ([
        ["0-10",4],
        ["11-20",2],
        ["21-30",0],
        ["31-40",1],
        ["41-50",0],
        ["51-60",0],
        ["61-70",0],
        ["71-80",1],
        ["81-90",2],
        ["91-100",3] ]))

test "Continuous Buckets", ()->
    active_config = configs[3]
    ratings = [-1,0,1,1,3,5,6,6,6,8,10,11]
    deepEqual(stratify(ratings, active_config), ([
        ["0",1],
        ["1",2],
        ["2",0],
        ["3",1],
        ["4",0],
        ["5",1],
        ["6",3],
        ["7",0],
        ["8",1],
        ["9",0],
        ["10",1] ]))
    shuf_ratings = _.shuffle(ratings)
    deepEqual(stratify(shuf_ratings, active_config), ([
        ["0",1],
        ["1",2],
        ["2",0],
        ["3",1],
        ["4",0],
        ["5",1],
        ["6",3],
        ["7",0],
        ["8",1],
        ["9",0],
        ["10",1] ]))


local db = {}

db.race = {
	kingdom = 1,
	forest = 2,
	wild = 3,
	hell = 4,
}

db.card  = import '.cardDB'
db.skill = import '.skillDB'

return db
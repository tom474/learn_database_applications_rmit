// Problem 1: MongoDB
db.teams.insertMany([
	{
		_id: 1,
		name: "Manchester United",
		points: 3,
		matches: [
			{ opponent_id: 2, goals: -2 },
			{ opponent_id: 3, goals: 1 },
			{ opponent_id: 4, goals: 1 },
		],
	},
	{
		_id: 2,
		name: "Barcelona",
		points: 5,
		matches: [
			{ opponent_id: 1, goals: 0 },
			{ opponent_id: 3, goals: -1 },
			{ opponent_id: 4, goals: 1 },
		],
	},
	{
		_id: 3,
		name: "RMIT",
		points: 7,
		matches: [
			{ opponent_id: 1, goals: -2 },
			{ opponent_id: 2, goals: 0 },
			{ opponent_id: 4, goals: -1 },
		],
	},
	{
		_id: 4,
		name: "Cuong",
		points: 5,
		matches: [
			{ opponent_id: 1, goals: 0 },
			{ opponent_id: 2, goals: 0 },
			{ opponent_id: 3, goals: 1 },
		],
	},
]);

db.teams.find().sort({ points: -1 }).limit(2);

db.teams.find({ "matches.goals": { $not: { $lt: 0 } } });

db.teams.find({ matches: { $elemMatch: { opponent_id: 4, goals: { $lt: 0 } } } });

db.teams.aggregate([
    {
        $match: { _id: 4 },
    },
    {
        $unwind: "$matches",
    },
    {
        $match: { "matches.goals": { $gt: 0 } },
    },
    {
        $count: "number_of_wins",
    },
]);

// Exercise 1: Working with embedded documents
// Find the students who score more than 99 on any type of work
db.students.find({ "scores.score": { $gt: 99 } });

// Find the students who score more than 99 on "homework"
db.students.find({ scores: { $elemMatch: { score: { $gt: 99 }, type: "homework" } } });

// Find the students who score more than 90 on all types of works
db.students.find({ "scores.score": { $not: { $lte: 90 } } });

// Add a field ("grade": "excellent") to the first element of the "scores" array which has a score value >= 80. Do this for one student only
db.students.updateOne({ "scores.score": { $gte: 80 } }, { $set: { "scores.$.grade": "excellent" } });

// Add a new element { score: 100, type: "overall" } to the end of the "scores" array of the student whose _id = 0
db.students.updateOne({ _id: 0 }, { $push: { scores: { score: 100, type: "overall" } } });

// Remove the last element in the "scores" array of the student whose _id = 0
db.students.updateOne({ _id: 0 }, { $pop: { scores: 1 } });


// Exercise 2: Using the aggregation pipeline
// Display all products and related components
db.products.aggregate([
	{
		$lookup: {
			localField: "_id",
			from: "components",
			foreignField: "for",
			as: "productComponents",
		},
	},
]);

// Do the following steps in one pipeline:
// Stage 1: Calculate the total price of all components belonging to each product
// Stage 2: Sort the products by total price in descending order
// Stage 3: Return only the product id, name, and total price
db.products.aggregate([
	{
		$lookup: {
			localField: "_id",
			from: "components",
			foreignField: "for",
			as: "productComponents",
		},
	},
	{
		$unwind: "$productComponents",
	},
	{
		$group: {
			_id: { product_id: "$_id", name: "$name" },
			totalPrice: { $sum: "$productComponents.price" },
		},
	},
	{
		$addFields: {
			product_id: "$_id.product_id",
			name: "$_id.name",
		},
	},
	{
		$project: {
			_id: 0,
			product_id: 1,
			name: 1,
			totalPrice: 1,
		},
	},
	{
		$sort: { totalPrice: -1 },
	},
]);

// Do the following steps in one pipeline
// Stage 1: Add a new field "total_score" to each document in the "students" collection. This field stores the sum of all scores for a student
// Stage 2: Keep only documents whose "total_score" is >= 200
// Stage 3: Sort the data by "total_score" in descending order
// Stage 4: Keep only the _id, name, and "total_score" fields for each document
// Stage 5: Return a maximum of 5 such documents
db.students.aggregate([
	{
		$addFields: {
			total_score: { $sum: "$scores.score" },
		},
	},
	{
		$match: {
			total_score: { $gte: 200 },
		},
	},
	{
		$sort: {
			total_score: -1,
		},
	},
	{
		$project: {
			_id: 1,
			name: 1,
			total_score: 1,
		},
	},
	{
		$limit: 5,
	},
]);

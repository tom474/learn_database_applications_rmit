// Exercise 1: Getting Started
db.courses.insertOne({ code: "ISYS2099", name: "Database Applications", year: 3 });
db.courses.find();
db.books.find().limit(2);


// Exercise 2: Querying data
// Write a statement to get all book documents
db.books.find();

// Write a statement to get all books' title, ISBN, and number of pages
db.books.find({}, { title: 1, isbn: 1, pageCount: 1 });

// Write a statement to get all books whose title is "Test Driven"
db.books.find({ title: "Test Driven" });

// Write a statement to get all books that have more than 500 pages
db.books.find({ pageCount: { $gt: 500 } });

// Write a statement to get all books that have more than 500 pages and less than 600 pages
db.books.find({ pageCount: { $gt: 500, $lt: 600 } });

// Write a statement to get all books that have more than 1000 pages OR (less than 200 pages but still > 0)
db.books.find({ $or: [{ pageCount: { $gt: 1000 } }, { pageCount: { $lt: 200, $gt: 0 } }] });

// Write a statement to get all books whose title contains the word "Android"
db.books.find({ title: /Android/ });

// Write 2 statements to get all books whose title starts/ends with "Java"
db.books.find({ title: { $regex: /^Java/ } });
db.books.find({ title: { $regex: /Java$/ } });

// Write a statement to get all books written by "Robi Sen"
db.books.find({ authors: "Robi Sen" });
db.books.find({ authors: { $all: ["Robi Sen"] } });

// Write a statement to count how many books belong to the category "Java"
db.books.find({ categories: "Java" }).count();


// Exercise 3: Modifying data
// Write a statement to insert several new book documents into the "books" collection.
// You can freely decide the fields that you want each book document to have.
// The inserted book documents can have different fields as well
db.books.insertMany([
	{ title: "Best Book Ever 1", pageCount: 1001, price: 99.9 },
	{ title: "Best Book Ever 2", pageCount: 1001, price: 99.9 },
]);

// Write a statement to update one or more book documents
db.books.updateMany({ price: { $gt: 1 } }, { $set: { price: 1.1 } });

// Write a statement to delete one or more book document
db.books.deleteMany({ pageCount: 0 });

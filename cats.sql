CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "228 East 6th Street"), (2, "165 Duane Street");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Alex", "Harris", 1),
  (2, "Jenn", "Diclemente", 1),
  (3, "Cody", "Pizzaia", 2),
  (4, "Homeless", "Hobo", NULL);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, "Garlic", 1),
  (2, "Spinach", 2),
  (3, "Artichoke", 3),
  (4, "Kitty", 3),
  (5, "Sad Kitty", NULL);

-- table creation
CREATE TABLE IF NOT EXISTS freelancers(
	freelancer_id TEXT NOT NULL,
	full_name TEXT,
	gender TEXT,
	age TEXT,
	country TEXT,
	languages TEXT,
	primary_skill TEXT,
	exp_years TEXT,
	hourly_rate TEXT,
	rating TEXT,
	is_active TEXT,
	client_satisfaction TEXT,
	PRIMARY KEY (freelancer_id)
)
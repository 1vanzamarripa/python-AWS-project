CREATE TABLE hardware (
  id serial primary key,
  provider text not null,
  name text not null);

INSERT INTO hardware(provider, name) VALUES ('Amazon', 'c5');
INSERT INTO hardware(provider, name) VALUES ('Azure', 'H16mr');

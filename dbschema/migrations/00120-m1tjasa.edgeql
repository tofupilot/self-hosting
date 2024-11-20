CREATE MIGRATION m1tjasa6dnrbixz7pts4wfquksiknwgjeg4roouqjcjnodowcuk7kq
    ONTO m1jo3vyw7vvj6rrpxvhgosfv7r3hkmn7bn2kbse6dqlldoo356rj2q
{
  CREATE TYPE activity::UserVisit EXTENDING activity::Activity {
      CREATE REQUIRED PROPERTY path: std::str;
  };
};

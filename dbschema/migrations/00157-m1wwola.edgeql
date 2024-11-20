CREATE MIGRATION m1wwolab7fnxbmmolgsbvp2sfyqdu5j6jt6r3s3k6g5u45oe45ip7a
    ONTO m14rylyh5slklxsjgnwrvjqjvykohbmua374cega2cojqiwcuwdisa
{
  ALTER TYPE default::Action {
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
  ALTER TYPE default::Defect {
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
  ALTER TYPE default::Procedure {
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
  ALTER TYPE default::Requirement {
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
  ALTER TYPE default::Unit {
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
  ALTER TYPE design::Revision {
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .component));
  };
};

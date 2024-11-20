CREATE MIGRATION m1jd3jh2pyol4xi2dary7raxrpgtbpwha3v44jncgdhytj4q2o42fq
    ONTO m1zbmd27fyejl5worr465bmycianhf2woui7q3mitaebp3ojov7atq
{
  ALTER TYPE default::User {
      ALTER PROPERTY superAdmin {
          SET readonly := true;
      };
  };
};

CREATE MIGRATION m1x7rrwqzdqemvadjk6fzq37gfsfd7p6tmqepteyvzkkxufqtco5va
    ONTO m1jd3jh2pyol4xi2dary7raxrpgtbpwha3v44jncgdhytj4q2o42fq
{
  ALTER TYPE default::User {
      ALTER PROPERTY superAdmin {
          RESET readonly;
      };
  };
};

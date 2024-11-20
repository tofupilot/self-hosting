CREATE MIGRATION m1c7bhoqn5oaafpxrx57vnzb2up5pd5hp3jaanwb2diwvt2g4ehfva
    ONTO m133jrexohrufdrfgiqqa4jfsnpkd7a7gpihpkxkk5hzgsme4fz42a
{
  ALTER TYPE view::Condition {
      ALTER LINK filters {
          ON TARGET DELETE ALLOW;
      };
  };
};

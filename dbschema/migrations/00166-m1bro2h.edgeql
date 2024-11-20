CREATE MIGRATION m1bro2hhjcsjhruuskkh2ud7nuhyvyfeklcvzyneoxoevcj4ctqljq
    ONTO m1u2ciqcqnnnfpjgrqhquamu5dpcimmkb7zeqlzlszwpovmqjljava
{
  ALTER TYPE relation::RequirementToDesign {
      ALTER LINK evidences {
          ON TARGET DELETE ALLOW;
      };
  };
};

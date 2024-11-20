CREATE MIGRATION m1cdhhsxdlpwyp3zwbmpohdoviixg465iejwmlswmulbxx4u3ab7rq
    ONTO m1uuizccaxev4ylmmwqxqffvked6nj34xepgnh23pg4h67bulbbnja
{
  ALTER TYPE default::Organization {
      ALTER PROPERTY copilotFeatureFlag {
          RENAME TO featureFlagQC;
      };
  };
  ALTER TYPE default::Organization {
      ALTER PROPERTY featureFlagQC {
          SET default := true;
      };
  };
};

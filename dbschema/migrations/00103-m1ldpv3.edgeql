CREATE MIGRATION m1ldpv3yjo5wmjvj64f7zh7hwhiem2nht2yeaxwcbnbx6asshk2q2q
    ONTO m12cmdi4zlnajsiz4zraaoiwryxsngupdi2nxvsb2qal3yet2ue65a
{
  ALTER SCALAR TYPE analytics::ObjectiveType EXTENDING enum<ApprovedRequirements, CoveragePlanRequirement, CoverageDesignRequirement, ApprovedPlans, ApprovedDesigns, ValidatedDesigns>;
};

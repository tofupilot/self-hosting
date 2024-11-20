CREATE MIGRATION m1t7gfcq6y4gaxpl7xjdlaxztanwdjtk6hfp2nx46epulfqnkryzaq
    ONTO m1xc5tmwxa4xvti24qh5iufoktsgox2jx5ebupe7bl4q5nehqp4t7a
{
  ALTER SCALAR TYPE analytics::ObjectiveType EXTENDING enum<ApprovedRequirements, CoverageProcedureRequirement, CoverageDesignRequirement, ApprovedProcedures, ApprovedDesigns, ValidatedDesigns>;
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Requirement, Design, Procedure, Action, Asset, Defect>;
};

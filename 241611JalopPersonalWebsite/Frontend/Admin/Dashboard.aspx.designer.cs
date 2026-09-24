namespace _241611JalopPersonalWebsite.Frontend.Admin
{
    public partial class Dashboard
    {
        protected global::System.Web.UI.HtmlControls.HtmlForm adminForm;
        protected global::System.Web.UI.WebControls.Literal litAdminName;
        protected global::System.Web.UI.WebControls.HyperLink lnkViewPublicPortfolio;
        protected global::_241611JalopPersonalWebsite.Frontend.User.Controls.UserMenu ucUserMenu;
        protected global::System.Web.UI.WebControls.Panel pnlSuccess;
        protected global::System.Web.UI.WebControls.Literal lblSuccessMessage;
        protected global::System.Web.UI.WebControls.Panel pnlError;
        protected global::System.Web.UI.WebControls.Literal lblErrorMessage;
        protected global::System.Web.UI.WebControls.Literal litTotalUsers;
        protected global::System.Web.UI.WebControls.Literal litTotalActive;
        protected global::System.Web.UI.WebControls.Literal litTotalInactive;
        protected global::System.Web.UI.WebControls.TextBox txtSearch;
        protected global::System.Web.UI.WebControls.DropDownList ddlStatusFilter;
        protected global::System.Web.UI.WebControls.DropDownList ddlRoleFilter;
        protected global::System.Web.UI.WebControls.Button btnResetFilter;
        protected global::System.Web.UI.WebControls.Repeater rptUsers;
        protected global::System.Web.UI.WebControls.Panel pnlNoUsers;
        
        // User Summary Modal Controls
        protected global::System.Web.UI.WebControls.Panel pnlUserSummaryModal;
        protected global::System.Web.UI.WebControls.LinkButton btnCloseSummaryX;
        protected global::System.Web.UI.WebControls.HiddenField hfSummaryUserId;
        protected global::System.Web.UI.WebControls.HiddenField hfSummaryCurrentStatus;
        protected global::System.Web.UI.WebControls.HiddenField hfSummaryFirstName;
        protected global::System.Web.UI.WebControls.HiddenField hfSummaryLastName;
        protected global::System.Web.UI.WebControls.HiddenField hfSummaryEmailRaw;
        protected global::System.Web.UI.WebControls.HiddenField hfSummaryRoleRaw;
        protected global::System.Web.UI.WebControls.Literal litSummaryAvatarInitials;
        protected global::System.Web.UI.WebControls.Literal litSummaryFullName;
        protected global::System.Web.UI.WebControls.Literal litSummaryEmail;
        protected global::System.Web.UI.WebControls.Literal litSummaryRoleBadge;
        protected global::System.Web.UI.WebControls.Literal litSummaryStatusBadge;
        protected global::System.Web.UI.WebControls.Literal litSummaryEduCount;
        protected global::System.Web.UI.WebControls.Literal litSummarySkillCount;
        protected global::System.Web.UI.WebControls.Literal litSummaryHobbyCount;
        protected global::System.Web.UI.WebControls.Literal litSummaryAffilCount;
        protected global::System.Web.UI.WebControls.Literal litSummarySocialCount;
        protected global::System.Web.UI.WebControls.Literal litSummaryUserId;
        protected global::System.Web.UI.WebControls.Literal litSummaryContactEmail;
        protected global::System.Web.UI.WebControls.Literal litSummaryContactNum;
        protected global::System.Web.UI.WebControls.Literal litSummaryAddress;
        protected global::System.Web.UI.WebControls.Literal litSummaryBirthday;
        protected global::System.Web.UI.WebControls.Literal litSummaryCreatedAt;
        protected global::System.Web.UI.WebControls.Literal litSummaryBio;
        protected global::System.Web.UI.WebControls.Repeater rptSummaryEducations;
        protected global::System.Web.UI.WebControls.Label lblNoEducations;
        protected global::System.Web.UI.WebControls.Repeater rptSummaryAffiliations;
        protected global::System.Web.UI.WebControls.Label lblNoAffiliations;
        protected global::System.Web.UI.WebControls.Repeater rptSummarySkills;
        protected global::System.Web.UI.WebControls.Label lblNoSkills;
        protected global::System.Web.UI.WebControls.Repeater rptSummaryHobbies;
        protected global::System.Web.UI.WebControls.Label lblNoHobbies;
        protected global::System.Web.UI.WebControls.Repeater rptSummarySocialLinks;
        protected global::System.Web.UI.WebControls.Label lblNoSocialLinks;
        protected global::System.Web.UI.HtmlControls.HtmlButton btnSummaryStatusTrigger;
        protected global::System.Web.UI.WebControls.Literal litSummaryStatusBtnText;
        protected global::System.Web.UI.WebControls.HyperLink lnkSummaryPortfolio;
        protected global::System.Web.UI.WebControls.HyperLink lnkSummaryEditPortfolio;
        protected global::System.Web.UI.WebControls.Button btnCloseSummary;

        // Proper Status Modal Controls
        protected global::System.Web.UI.WebControls.HiddenField hfStatusUserId;
        protected global::System.Web.UI.WebControls.HiddenField hfStatusNewState;
        protected global::System.Web.UI.WebControls.Button btnConfirmStatusAction;

        // Proper Delete Modal Controls
        protected global::System.Web.UI.WebControls.HiddenField hfDeleteUserId;
        protected global::System.Web.UI.WebControls.Button btnConfirmDeleteUser;

        // Add Modal Controls
        protected global::System.Web.UI.WebControls.TextBox txtAddFirstName;
        protected global::System.Web.UI.WebControls.TextBox txtAddLastName;
        protected global::System.Web.UI.WebControls.TextBox txtAddEmail;
        protected global::System.Web.UI.WebControls.TextBox txtAddPassword;
        protected global::System.Web.UI.WebControls.DropDownList ddlAddRole;
        protected global::System.Web.UI.WebControls.CheckBox chkAddIsActive;
        protected global::System.Web.UI.WebControls.Button btnSaveNewUser;

        // Edit Modal Controls
        protected global::System.Web.UI.WebControls.HiddenField hfEditUserId;
        protected global::System.Web.UI.WebControls.TextBox txtEditFirstName;
        protected global::System.Web.UI.WebControls.TextBox txtEditLastName;
        protected global::System.Web.UI.WebControls.TextBox txtEditEmail;
        protected global::System.Web.UI.WebControls.DropDownList ddlEditRole;
        protected global::System.Web.UI.WebControls.CheckBox chkEditIsActive;
        protected global::System.Web.UI.WebControls.TextBox txtEditNewPassword;
        protected global::System.Web.UI.WebControls.TextBox txtEditConfirmPassword;
        protected global::System.Web.UI.WebControls.Button btnUpdateUser;
    }
}

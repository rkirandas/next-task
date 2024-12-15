using Microsoft.Data.Tools.Schema.Sql.UnitTesting;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;

namespace nexttask_db_tests
{
    [TestClass()]
    public class NextTask_DBTests : SqlDatabaseTestClass
    {

        public NextTask_DBTests()
        {
            InitializeComponent();
        }

        [TestInitialize()]
        public void TestInitialize()
        {
            base.InitializeTest();
        }
        [TestCleanup()]
        public void TestCleanup()
        {
            base.CleanupTest();
        }

        #region Designer support code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction AddTask_Success_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(NextTask_DBTests));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition addtask_success;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition addtask_anonymoususer_added;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction UpdateTask_Success_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition updatetask_success;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition updatetask_title_updated;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction ArchiveTask_Success_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.EmptyResultSetCondition archivetask_result;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition archivetask_success;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction UpdateTask_Error_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition updatetask_user_err;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction AddTask_AnonyUserLimit_Success_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition addtask_anonyuser_tasklimit;
            this.AddTask_SuccessData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.UpdateTask_SuccessData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.ArchiveTask_SuccessData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.UpdateTask_ErrorData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.AddTask_AnonyUserLimit_SuccessData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            AddTask_Success_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            addtask_success = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            addtask_anonymoususer_added = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            UpdateTask_Success_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            updatetask_success = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            updatetask_title_updated = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            ArchiveTask_Success_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            archivetask_result = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.EmptyResultSetCondition();
            archivetask_success = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            UpdateTask_Error_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            updatetask_user_err = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            AddTask_AnonyUserLimit_Success_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            addtask_anonyuser_tasklimit = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            // 
            // AddTask_Success_TestAction
            // 
            AddTask_Success_TestAction.Conditions.Add(addtask_success);
            AddTask_Success_TestAction.Conditions.Add(addtask_anonymoususer_added);
            resources.ApplyResources(AddTask_Success_TestAction, "AddTask_Success_TestAction");
            // 
            // addtask_success
            // 
            addtask_success.ColumnNumber = 1;
            addtask_success.Enabled = true;
            addtask_success.ExpectedValue = "0";
            addtask_success.Name = "addtask_success";
            addtask_success.NullExpected = false;
            addtask_success.ResultSet = 1;
            addtask_success.RowNumber = 1;
            // 
            // addtask_anonymoususer_added
            // 
            addtask_anonymoususer_added.ColumnNumber = 3;
            addtask_anonymoususer_added.Enabled = true;
            addtask_anonymoususer_added.ExpectedValue = "5";
            addtask_anonymoususer_added.Name = "addtask_anonymoususer_added";
            addtask_anonymoususer_added.NullExpected = false;
            addtask_anonymoususer_added.ResultSet = 3;
            addtask_anonymoususer_added.RowNumber = 1;
            // 
            // UpdateTask_Success_TestAction
            // 
            UpdateTask_Success_TestAction.Conditions.Add(updatetask_success);
            UpdateTask_Success_TestAction.Conditions.Add(updatetask_title_updated);
            resources.ApplyResources(UpdateTask_Success_TestAction, "UpdateTask_Success_TestAction");
            // 
            // updatetask_success
            // 
            updatetask_success.ColumnNumber = 1;
            updatetask_success.Enabled = true;
            updatetask_success.ExpectedValue = "0";
            updatetask_success.Name = "updatetask_success";
            updatetask_success.NullExpected = false;
            updatetask_success.ResultSet = 1;
            updatetask_success.RowNumber = 1;
            // 
            // updatetask_title_updated
            // 
            updatetask_title_updated.ColumnNumber = 2;
            updatetask_title_updated.Enabled = true;
            updatetask_title_updated.ExpectedValue = "TEST UPDATED";
            updatetask_title_updated.Name = "updatetask_title_updated";
            updatetask_title_updated.NullExpected = false;
            updatetask_title_updated.ResultSet = 2;
            updatetask_title_updated.RowNumber = 1;
            // 
            // ArchiveTask_Success_TestAction
            // 
            ArchiveTask_Success_TestAction.Conditions.Add(archivetask_result);
            ArchiveTask_Success_TestAction.Conditions.Add(archivetask_success);
            resources.ApplyResources(ArchiveTask_Success_TestAction, "ArchiveTask_Success_TestAction");
            // 
            // archivetask_result
            // 
            archivetask_result.Enabled = true;
            archivetask_result.Name = "archivetask_result";
            archivetask_result.ResultSet = 2;
            // 
            // archivetask_success
            // 
            archivetask_success.ColumnNumber = 1;
            archivetask_success.Enabled = true;
            archivetask_success.ExpectedValue = "0";
            archivetask_success.Name = "archivetask_success";
            archivetask_success.NullExpected = false;
            archivetask_success.ResultSet = 1;
            archivetask_success.RowNumber = 1;
            // 
            // UpdateTask_Error_TestAction
            // 
            UpdateTask_Error_TestAction.Conditions.Add(updatetask_user_err);
            resources.ApplyResources(UpdateTask_Error_TestAction, "UpdateTask_Error_TestAction");
            // 
            // updatetask_user_err
            // 
            updatetask_user_err.ColumnNumber = 1;
            updatetask_user_err.Enabled = true;
            updatetask_user_err.ExpectedValue = "1";
            updatetask_user_err.Name = "updatetask_user_err";
            updatetask_user_err.NullExpected = false;
            updatetask_user_err.ResultSet = 1;
            updatetask_user_err.RowNumber = 1;
            // 
            // AddTask_AnonyUserLimit_Success_TestAction
            // 
            AddTask_AnonyUserLimit_Success_TestAction.Conditions.Add(addtask_anonyuser_tasklimit);
            resources.ApplyResources(AddTask_AnonyUserLimit_Success_TestAction, "AddTask_AnonyUserLimit_Success_TestAction");
            // 
            // addtask_anonyuser_tasklimit
            // 
            addtask_anonyuser_tasklimit.ColumnNumber = 1;
            addtask_anonyuser_tasklimit.Enabled = true;
            addtask_anonyuser_tasklimit.ExpectedValue = "1";
            addtask_anonyuser_tasklimit.Name = "addtask_anonyuser_tasklimit";
            addtask_anonyuser_tasklimit.NullExpected = false;
            addtask_anonyuser_tasklimit.ResultSet = 1;
            addtask_anonyuser_tasklimit.RowNumber = 1;
            // 
            // AddTask_SuccessData
            // 
            this.AddTask_SuccessData.PosttestAction = null;
            this.AddTask_SuccessData.PretestAction = null;
            this.AddTask_SuccessData.TestAction = AddTask_Success_TestAction;
            // 
            // UpdateTask_SuccessData
            // 
            this.UpdateTask_SuccessData.PosttestAction = null;
            this.UpdateTask_SuccessData.PretestAction = null;
            this.UpdateTask_SuccessData.TestAction = UpdateTask_Success_TestAction;
            // 
            // ArchiveTask_SuccessData
            // 
            this.ArchiveTask_SuccessData.PosttestAction = null;
            this.ArchiveTask_SuccessData.PretestAction = null;
            this.ArchiveTask_SuccessData.TestAction = ArchiveTask_Success_TestAction;
            // 
            // UpdateTask_ErrorData
            // 
            this.UpdateTask_ErrorData.PosttestAction = null;
            this.UpdateTask_ErrorData.PretestAction = null;
            this.UpdateTask_ErrorData.TestAction = UpdateTask_Error_TestAction;
            // 
            // AddTask_AnonyUserLimit_SuccessData
            // 
            this.AddTask_AnonyUserLimit_SuccessData.PosttestAction = null;
            this.AddTask_AnonyUserLimit_SuccessData.PretestAction = null;
            this.AddTask_AnonyUserLimit_SuccessData.TestAction = AddTask_AnonyUserLimit_Success_TestAction;
        }

        #endregion


        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        #endregion

        [TestMethod()]
        public void AddTask_Success()
        {
            SqlDatabaseTestActions testActions = this.AddTask_SuccessData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }

        [TestMethod()]
        public void UpdateTask_Success()
        {
            SqlDatabaseTestActions testActions = this.UpdateTask_SuccessData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }
        [TestMethod()]
        public void ArchiveTask_Success()
        {
            SqlDatabaseTestActions testActions = this.ArchiveTask_SuccessData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }
        [TestMethod()]
        public void UpdateTask_Error()
        {
            SqlDatabaseTestActions testActions = this.UpdateTask_ErrorData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }
        [TestMethod()]
        public void AddTask_AnonyUserLimit_Success()
        {
            SqlDatabaseTestActions testActions = this.AddTask_AnonyUserLimit_SuccessData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }




        private SqlDatabaseTestActions AddTask_SuccessData;
        private SqlDatabaseTestActions UpdateTask_SuccessData;
        private SqlDatabaseTestActions ArchiveTask_SuccessData;
        private SqlDatabaseTestActions UpdateTask_ErrorData;
        private SqlDatabaseTestActions AddTask_AnonyUserLimit_SuccessData;
    }
}

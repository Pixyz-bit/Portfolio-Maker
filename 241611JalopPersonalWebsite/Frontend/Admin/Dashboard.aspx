<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.Admin.Dashboard" %>
<%@ Register Src="~/Frontend/User/Controls/UserMenu.ascx" TagPrefix="uc" TagName="UserMenu" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Console | Portfolio OS</title>
    <meta name="description" content="Administrator dashboard for user management, system analytics, and account administration." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

    <style>
        :root {
            --bg-canvas: #ffffff;
            --border-black: #000000;
            --text-black: #000000;
            --text-sub: #18181b;
            --text-muted: #52525b;
            --card-bg: #ffffff;
            --radius-card: 18px;
            --radius-btn: 10px;
            --radius-pill: 999px;
            --transition: 0.18s ease;
            --shadow-neo: 4px 4px 0px #000000;
            --shadow-neo-sm: 2px 2px 0px #000000;
            --shadow-neo-hover: 6px 6px 0px #000000;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: #ffffff;
            color: var(--text-black);
            min-height: 100vh;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        h1, h2, h3, h4, h5, .font-heading {
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .admin-nav {
            position: sticky;
            top: 0;
            z-index: 100;
            background-color: #ffffff;
            border-bottom: 2.5px solid var(--border-black);
            padding: 14px 28px;
        }

        .nav-inner {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }

        .nav-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: var(--text-black);
        }

        .brand-badge {
            background-color: #000000;
            color: #ffffff;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 0.78rem;
            letter-spacing: 0.05em;
            padding: 4px 10px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .brand-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.15rem;
            font-weight: 800;
            letter-spacing: -0.02em;
        }

        .nav-user {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .user-tag {
            font-size: 0.88rem;
            font-weight: 600;
            background-color: #f4f4f5;
            border: 2px solid var(--border-black);
            padding: 6px 14px;
            border-radius: var(--radius-pill);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .user-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: #10b981;
            display: inline-block;
        }

        .btn {
            height: 40px;
            padding: 0 18px;
            border-radius: var(--radius-btn);
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 0.88rem;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: var(--transition);
            white-space: nowrap;
            border: 2px solid var(--border-black);
        }

        .btn-sm,
        .actions-cell .btn,
        .actions-cell a.btn,
        .actions-cell button.btn,
        .modal-actions .btn {
            height: 32px;
            padding: 0 12px;
            font-size: 0.8rem;
            font-weight: 700;
            border-radius: 6px;
            border-width: 1.5px;
            box-shadow: none !important;
            transform: none !important;
        }

        .btn-sm:hover,
        .actions-cell .btn:hover,
        .actions-cell a.btn:hover,
        .actions-cell button.btn:hover,
        .modal-actions .btn:hover {
            box-shadow: none !important;
            transform: none !important;
        }

        .btn-solid {
            background-color: #000000;
            color: #ffffff;
            box-shadow: none !important;
        }

        .btn-solid:hover {
            background-color: #27272a;
        }

        .btn-outline {
            background-color: #ffffff;
            color: #000000;
            box-shadow: none !important;
        }

        .btn-outline:hover {
            background-color: #f4f4f5;
        }

        .btn-danger {
            background-color: #fee2e2;
            color: #991b1b;
            border-color: #991b1b;
            box-shadow: none !important;
        }

        .btn-danger:hover {
            background-color: #fecaca;
        }

        .btn-success {
            background-color: #dcfce7;
            color: #166534;
            border-color: #166534;
            box-shadow: none !important;
        }

        .btn-success:hover {
            background-color: #bbf7d0;
        }

        .admin-main {
            max-width: 1200px;
            margin: 0 auto;
            padding: 32px 24px 60px;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .page-title {
            font-size: 1.85rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: var(--text-black);
        }

        .page-subtitle {
            font-size: 0.95rem;
            color: var(--text-muted);
            margin-top: 4px;
        }

        .toast-container {
            position: fixed;
            bottom: 24px;
            right: 24px;
            z-index: 100000;
            display: flex;
            flex-direction: column;
            gap: 12px;
            max-width: 420px;
            width: calc(100vw - 48px);
            pointer-events: none;
        }

        .toast-box {
            pointer-events: auto;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 14px 18px;
            border-radius: 12px;
            border: 2px solid #000000;
            box-shadow: 4px 4px 0px #000000;
            background-color: #ffffff;
            animation: toastSlideUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
            transition: opacity 0.25s ease, transform 0.25s ease;
        }

        @keyframes toastSlideUp {
            from {
                opacity: 0;
                transform: translateY(24px) scale(0.96);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .toast-box.toast-error {
            background-color: #fef2f2;
            border-color: #ef4444;
            color: #991b1b;
            box-shadow: 4px 4px 0px #ef4444;
        }

        .toast-box.toast-success {
            background-color: #f0fdf4;
            border-color: #16a34a;
            color: #166534;
            box-shadow: 4px 4px 0px #16a34a;
        }

        .toast-icon {
            flex-shrink: 0;
            margin-top: 2px;
        }

        .toast-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 3px;
        }

        .toast-title {
            font-size: 0.85rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            line-height: 1.2;
        }

        .toast-message {
            font-size: 0.88rem;
            font-weight: 600;
            line-height: 1.4;
        }

        .toast-close-btn {
            background: transparent;
            border: none;
            font-size: 1.3rem;
            line-height: 1;
            cursor: pointer;
            color: inherit;
            padding: 0 2px;
            font-weight: 800;
            opacity: 0.75;
            transition: opacity 0.2s ease;
        }

        .toast-close-btn:hover {
            opacity: 1;
        }

        @media (max-width: 480px) {
            .toast-container {
                bottom: 16px;
                right: 16px;
                left: 16px;
                width: auto;
                max-width: none;
            }
        }

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 36px;
        }

        .metric-card {
            background-color: var(--card-bg);
            border: 2.5px solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 24px;
            box-shadow: var(--shadow-neo);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: var(--transition);
        }

        .metric-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-neo-hover);
        }

        .metric-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
        }

        .metric-label {
            font-size: 0.88rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: var(--text-muted);
        }

        .metric-icon {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            border: 2px solid var(--border-black);
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f4f4f5;
        }

        .metric-value {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 2.4rem;
            font-weight: 800;
            line-height: 1;
            letter-spacing: -0.03em;
            margin-bottom: 8px;
        }

        .metric-desc {
            font-size: 0.85rem;
            color: var(--text-muted);
        }

        .content-card {
            background-color: var(--card-bg);
            border: 2.5px solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 28px;
            box-shadow: var(--shadow-neo);
        }

        .table-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            flex: 1;
        }

        .input-box, .select-box {
            height: 40px;
            padding: 0 14px;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-btn);
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            background-color: #ffffff;
            outline: none;
            transition: var(--transition);
        }

        .input-box:focus, .select-box:focus {
            box-shadow: var(--shadow-neo-sm);
        }

        .search-input {
            min-width: 240px;
            flex: 1;
        }

        .table-responsive {
            width: 100%;
            overflow-x: auto;
            border: 2px solid var(--border-black);
            border-radius: 12px;
            background-color: #ffffff;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.92rem;
        }

        .data-table th {
            background-color: #f8fafc;
            color: var(--text-black);
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 14px 18px;
            border-bottom: 2px solid var(--border-black);
            white-space: nowrap;
        }

        .data-table td {
            padding: 14px 18px;
            border-bottom: 1.5px solid #e2e8f0;
            vertical-align: middle;
        }

        .data-table tr:last-child td {
            border-bottom: none;
        }

        .data-table tr:hover {
            background-color: #fafaf9;
        }

        .user-cell-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            background: none;
            border: none;
            padding: 4px 6px;
            border-radius: 8px;
            cursor: pointer;
            text-align: left;
            text-decoration: none;
            color: inherit;
            transition: background-color 0.15s ease;
        }

        .user-cell-btn:hover {
            background-color: #f1f5f9;
        }

        .user-cell-btn:hover .user-name-cell {
            text-decoration: underline;
        }

        .user-initials {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background-color: #000000;
            color: #ffffff;
            border: 2px solid var(--border-black);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 0.88rem;
            flex-shrink: 0;
        }

        .user-name-cell {
            font-weight: 700;
            color: var(--text-black);
            line-height: 1.25;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .user-email-cell {
            font-size: 0.82rem;
            color: var(--text-muted);
            line-height: 1.25;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: var(--radius-pill);
            font-size: 0.78rem;
            font-weight: 700;
            border: 1.5px solid var(--border-black);
            white-space: nowrap;
        }

        .badge-admin {
            background-color: #000000;
            color: #ffffff;
        }

        .badge-user {
            background-color: #ffffff;
            color: #000000;
        }

        .badge-active {
            background-color: #dcfce7;
            color: #15803d;
            border-color: #15803d;
        }

        .badge-inactive {
            background-color: #fee2e2;
            color: #b91c1c;
            border-color: #b91c1c;
        }

        .status-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background-color: currentColor;
        }

        .actions-cell {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .empty-state {
            padding: 48px 24px;
            text-align: center;
            color: var(--text-muted);
        }

        .empty-icon {
            margin-bottom: 12px;
        }

        /* Mobile Responsiveness for Toolbar and Table */
        @media (max-width: 768px) {
            .admin-main {
                padding: 20px 14px;
            }

            .content-card {
                padding: 18px 14px;
                border-radius: 14px;
            }

            .table-toolbar {
                margin-bottom: 16px;
            }

            .filter-group {
                flex-direction: column;
                align-items: stretch;
                width: 100%;
                gap: 10px;
            }

            .search-input {
                width: 100%;
                min-width: 0;
            }

            .filter-group .select-box {
                width: 100%;
            }

            .filter-group .btn {
                width: 100%;
                justify-content: center;
            }

            /* Transform Table into Mobile Card View */
            .table-responsive {
                border: none;
                background-color: transparent;
                overflow: visible;
            }

            .data-table,
            .data-table thead,
            .data-table tbody,
            .data-table tr,
            .data-table td {
                display: block;
                width: 100%;
            }

            .data-table thead {
                display: none;
            }

            .data-table tr.user-data-row {
                background-color: #ffffff;
                border: 2px solid var(--border-black);
                border-radius: 14px;
                margin-bottom: 14px;
                padding: 14px 16px;
                box-shadow: var(--shadow-neo-sm);
            }

            .data-table td {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 9px 0;
                border-bottom: 1px solid #f1f5f9;
                font-size: 0.88rem;
            }

            .data-table td:first-child {
                display: block;
                padding-top: 0;
                padding-bottom: 12px;
                border-bottom: 1.5px solid #e2e8f0;
            }

            .data-table td:last-child {
                border-bottom: none;
                padding-bottom: 0;
                padding-top: 12px;
                justify-content: flex-end;
            }

            .data-table td[data-label]::before {
                content: attr(data-label);
                font-family: 'Plus Jakarta Sans', sans-serif;
                font-size: 0.76rem;
                font-weight: 800;
                text-transform: uppercase;
                letter-spacing: 0.04em;
                color: var(--text-muted);
                margin-right: 12px;
                flex-shrink: 0;
            }

            .data-table td:first-child::before,
            .data-table td:last-child::before {
                display: none;
            }

            .actions-cell {
                width: 100%;
                justify-content: flex-end;
                gap: 8px;
            }

            .actions-cell .btn {
                flex: 1;
                text-align: center;
                justify-content: center;
                padding: 8px 12px;
            }
        }

        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.65);
            backdrop-filter: blur(4px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-box {
            background-color: #ffffff;
            border: 2.5px solid var(--border-black);
            border-radius: var(--radius-card);
            box-shadow: 8px 8px 0px #000000;
            width: 100%;
            max-width: 540px;
            padding: 32px;
            position: relative;
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-box-lg {
            max-width: 720px;
        }

        .modal-title {
            font-size: 1.45rem;
            font-weight: 800;
            margin-bottom: 6px;
            letter-spacing: -0.02em;
        }

        .modal-desc {
            font-size: 0.88rem;
            color: var(--text-muted);
            margin-bottom: 22px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 16px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-label {
            display: block;
            font-size: 0.85rem;
            font-weight: 700;
            margin-bottom: 6px;
            color: var(--text-black);
        }

        .form-control {
            width: 100%;
            height: 42px;
            padding: 0 14px;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-btn);
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            background-color: #ffffff;
            outline: none;
            transition: var(--transition);
        }

        .form-control:focus {
            box-shadow: var(--shadow-neo-sm);
        }

        .form-check {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 8px;
        }

        .form-check input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #000000;
        }

        .modal-actions {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 24px;
            padding-top: 18px;
            border-top: 2px solid #e2e8f0;
        }

        .close-modal-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            background: none;
            border: none;
            font-size: 1.4rem;
            line-height: 1;
            cursor: pointer;
            color: var(--text-muted);
        }

        .close-modal-btn:hover {
            color: var(--text-black);
        }

        /* User Summary Specific Styles */
        .summary-header-card {
            background-color: #f8fafc;
            border: 2px solid var(--border-black);
            border-radius: 12px;
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 20px;
        }

        .summary-avatar {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background-color: #000000;
            color: #ffffff;
            border: 2px solid var(--border-black);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.3rem;
            font-weight: 800;
            flex-shrink: 0;
        }

        .summary-details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
            margin-bottom: 20px;
        }

        .summary-item {
            background-color: #ffffff;
            border: 1.5px solid var(--border-black);
            border-radius: 8px;
            padding: 10px 14px;
        }

        .summary-item-label {
            font-size: 0.76rem;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 3px;
        }

        .summary-item-value {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-black);
            word-break: break-all;
        }

        .summary-stats-bar {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 8px;
            margin-bottom: 20px;
            text-align: center;
        }

        .summary-stat-box {
            border: 1.5px solid var(--border-black);
            border-radius: 8px;
            padding: 8px 4px;
            background-color: #fafafa;
        }

        .summary-stat-num {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 1.15rem;
        }

        .summary-stat-title {
            font-size: 0.72rem;
            color: var(--text-muted);
            text-transform: uppercase;
            font-weight: 700;
        }

        .summary-section-box {
            border: 1.5px solid var(--border-black);
            border-radius: 10px;
            padding: 12px 16px;
            margin-bottom: 14px;
            background-color: #ffffff;
        }

        .summary-section-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 0.88rem;
            font-weight: 800;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .summary-pill-list {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .summary-pill {
            background-color: #f1f5f9;
            border: 1.5px solid var(--border-black);
            border-radius: var(--radius-pill);
            padding: 3px 10px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .summary-pill-link {
            text-decoration: none;
            color: var(--text-black);
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.15s ease;
        }

        .summary-pill-link:hover {
            background-color: #000000;
            color: #ffffff;
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
    <form id="adminForm" runat="server">
        <nav class="admin-nav">
            <div class="nav-inner">
                <a href="Dashboard.aspx" class="nav-brand">
                    <span class="brand-badge"><!--<svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" style="display:inline-block; vertical-align:-1px; margin-right:3px;"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>-->ADMIN</span>
                    <span class="brand-title">Dashboard</span>
                </a>

                <div class="nav-user" style="display: flex; align-items: center; gap: 14px;">
                    <asp:Literal ID="litAdminName" runat="server" Visible="false" />
                    <asp:HyperLink ID="lnkViewPublicPortfolio" runat="server" NavigateUrl="../User/Portfolio.aspx" Target="_blank" CssClass="btn btn-outline btn-sm" Visible="false">
                        View Portfolio
                    </asp:HyperLink>
                    <uc:UserMenu ID="ucUserMenu" runat="server" />
                </div>
            </div>
        </nav>

        <main class="admin-main">
            <div class="page-header">
                <div>
                    <h1 class="page-title">System Dashboard & User Directory</h1>
                    <p class="page-subtitle">Track active accounts, manage privileges, and review user portfolios.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-solid btn-sm" onclick="openAddModal()">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        Add New User
                    </button>
                </div>
            </div>

            <div class="toast-container" id="toastContainer">
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="toast-box toast-success">
                    <div class="toast-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="toast-content">
                        <span class="toast-title">Success</span>
                        <span class="toast-message"><asp:Literal ID="lblSuccessMessage" runat="server" /></span>
                    </div>
                    <button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                </asp:Panel>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="toast-box toast-error">
                    <div class="toast-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    </div>
                    <div class="toast-content">
                        <span class="toast-title">Error</span>
                        <span class="toast-message"><asp:Literal ID="lblErrorMessage" runat="server" /></span>
                    </div>
                    <button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                </asp:Panel>
            </div>

            <section class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-top">
                        <span class="metric-label">Total Registered</span>
                        <!--<div class="metric-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        </div>-->
                    </div>
                    <div class="metric-value">
                        <asp:Literal ID="litTotalUsers" runat="server" Text="0" />
                    </div>
                    <div class="metric-desc">Total user accounts in dbo.Users</div>
                </div>

                <div class="metric-card">
                    <div class="metric-top">
                        <span class="metric-label">Active Users</span>
                        <!--<div class="metric-icon" style="background-color: #dcfce7;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        </div>-->
                    </div>
                    <div class="metric-value" style="color: #15803d;">
                        <asp:Literal ID="litTotalActive" runat="server" Text="0" />
                    </div>
                    <div class="metric-desc">Enabled accounts permitted to authenticate</div>
                </div>

                <div class="metric-card">
                    <div class="metric-top">
                        <span class="metric-label">Deactivated Users</span>
                        <!--<div class="metric-icon" style="background-color: #fee2e2;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#b91c1c" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                        </div>-->
                    </div>
                    <div class="metric-value" style="color: #b91c1c;">
                        <asp:Literal ID="litTotalInactive" runat="server" Text="0" />
                    </div>
                    <div class="metric-desc">Suspended or disabled user accounts</div>
                </div>
            </section>

            <section class="content-card">
                <div class="table-toolbar">
                    <div class="filter-group">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="input-box search-input" placeholder="Search by name or email address..." autocomplete="off" />
                        
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="select-box">
                            <asp:ListItem Value="" Text="All Statuses" />
                            <asp:ListItem Value="active" Text="Active Accounts" />
                            <asp:ListItem Value="inactive" Text="Deactivated Accounts" />
                        </asp:DropDownList>

                        <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="select-box">
                            <asp:ListItem Value="" Text="All Roles" />
                            <asp:ListItem Value="admin" Text="Administrators" />
                            <asp:ListItem Value="user" Text="Standard Users" />
                        </asp:DropDownList>

                        <asp:Button ID="btnResetFilter" runat="server" Text="Reset Filters" CssClass="btn btn-outline btn-sm" OnClientClick="resetClientUserFilters(); return false;" />
                    </div>
                </div>

                <div class="table-responsive">
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <HeaderTemplate>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>User Account (Click to View Summary)</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Registered Date</th>
                                        <th style="text-align: right;">Management Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr class="user-data-row" 
                                data-name="<%# Server.HtmlEncode((Eval("FullName")?.ToString() ?? "").ToLowerInvariant()) %>" 
                                data-email="<%# Server.HtmlEncode((Eval("Email")?.ToString() ?? "").ToLowerInvariant()) %>" 
                                data-role="<%# Server.HtmlEncode((Eval("Role")?.ToString() ?? "").ToLowerInvariant()) %>" 
                                data-status="<%# (bool)Eval("IsActive") ? "active" : "inactive" %>">
                                <td data-label="User Account">
                                    <asp:LinkButton ID="btnUserClick" runat="server" 
                                        CommandName="ViewSummary" 
                                        CommandArgument='<%# Eval("UserID") %>' 
                                        CssClass="user-cell-btn" 
                                        ToolTip="Click to view comprehensive user summary">
                                        <div class="user-initials">
                                            <%# GetInitials(Eval("FirstName")?.ToString(), Eval("LastName")?.ToString(), Eval("Email")?.ToString()) %>
                                        </div>
                                        <div>
                                            <div class="user-name-cell">
                                                <%# Eval("FullName") %>
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                                            </div>
                                            <div class="user-email-cell">
                                                <%# Eval("Email") %>
                                            </div>
                                        </div>
                                    </asp:LinkButton>
                                </td>
                                <td data-label="Role">
                                    <span class="badge <%# string.Equals(Eval("Role")?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user" %>">
                                        <%# Eval("Role") %>
                                    </span>
                                </td>
                                <td data-label="Status">
                                    <span class="badge <%# (bool)Eval("IsActive") ? "badge-active" : "badge-inactive" %>">
                                        <span class="status-dot"></span>
                                        <%# (bool)Eval("IsActive") ? "Active" : "Deactivated" %>
                                    </span>
                                </td>
                                <td data-label="Registered">
                                    <%# FormatPhilippineTime(Eval("CreatedAt")) %>
                                </td>
                                <td data-label="Actions">
                                    <div class="actions-cell" style="justify-content: flex-end;">
                                        <button type="button" 
                                            class='<%# (bool)Eval("IsActive") ? "btn btn-danger btn-sm" : "btn btn-success btn-sm" %>'
                                            onclick='openStatusModal(<%# Eval("UserID") %>, "<%# Server.HtmlEncode(Eval("FullName")?.ToString() ?? Eval("FirstName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("Email")?.ToString()) %>", <%# Eval("IsActive").ToString().ToLower() %>)'>
                                            <%# (bool)Eval("IsActive") ? "Deactivate" : "Activate" %>
                                        </button>

                                        <button type="button" class="btn btn-outline btn-sm"
                                            onclick='openEditModal(<%# Eval("UserID") %>, "<%# Server.HtmlEncode(Eval("FirstName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("LastName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("Email")?.ToString()) %>", "<%# Eval("Role") %>", <%# Eval("IsActive").ToString().ToLower() %>)'>
                                            Edit
                                        </button>

                                        <!-- Delete User Button (Proper Modal Trigger) 
                                        <button type="button" class="btn btn-danger btn-sm"
                                            onclick='openDeleteModal(<%# Eval("UserID") %>, "<%# Server.HtmlEncode(Eval("FullName")?.ToString() ?? Eval("FirstName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("Email")?.ToString()) %>")'>
                                            Delete
                                        </button>-->
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <div id="clientNoUsers" class="empty-state" style="display: none;">
                        <div class="empty-icon">
                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        </div>
                        <h4 style="margin-bottom: 4px;">No users match your criteria</h4>
                        <p>Try adjusting your search keywords or resetting the status and role filters.</p>
                    </div>

                    <asp:Panel ID="pnlNoUsers" runat="server" Visible="false" CssClass="empty-state">
                        <div class="empty-icon">
                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        </div>
                        <h4 style="margin-bottom: 4px;">No users in database</h4>
                        <p>No user records are currently registered.</p>
                    </asp:Panel>
                </div>
            </section>
        </main>

        <asp:Panel ID="pnlUserSummaryModal" runat="server" Visible="false" CssClass="modal-overlay active">
            <div class="modal-box modal-box-lg">
                <asp:LinkButton ID="btnCloseSummaryX" runat="server" CssClass="close-modal-btn" OnClick="btnCloseSummary_Click">&times;</asp:LinkButton>
                
                <h3 class="modal-title">User Account Summary</h3>
                <p class="modal-desc">Detailed profile information, activity statistics, and administrative controls.</p>

                <asp:HiddenField ID="hfSummaryUserId" runat="server" />
                <asp:HiddenField ID="hfSummaryCurrentStatus" runat="server" />
                <asp:HiddenField ID="hfSummaryFirstName" runat="server" />
                <asp:HiddenField ID="hfSummaryLastName" runat="server" />
                <asp:HiddenField ID="hfSummaryEmailRaw" runat="server" />
                <asp:HiddenField ID="hfSummaryRoleRaw" runat="server" />

                <div class="summary-header-card">
                    <div class="summary-avatar">
                        <asp:Literal ID="litSummaryAvatarInitials" runat="server" Text="U" />
                    </div>
                    <div style="flex: 1;">
                        <h4 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 2px;">
                            <asp:Literal ID="litSummaryFullName" runat="server" />
                        </h4>
                        <p style="font-size: 0.88rem; color: var(--text-muted); margin-bottom: 8px;">
                            <asp:Literal ID="litSummaryEmail" runat="server" />
                        </p>
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <asp:Literal ID="litSummaryRoleBadge" runat="server" />
                            <asp:Literal ID="litSummaryStatusBadge" runat="server" />
                        </div>
                    </div>
                </div>

                <div class="summary-stats-bar">
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummaryEduCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Education</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummarySkillCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Skills</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummaryHobbyCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Hobbies</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummaryAffilCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Affiliations</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummarySocialCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Socials</div>
                    </div>
                </div>

                <div class="summary-details-grid">
                    <div class="summary-item">
                        <div class="summary-item-label">User ID</div>
                        <div class="summary-item-value">#<asp:Literal ID="litSummaryUserId" runat="server" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Contact Email</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryContactEmail" runat="server" Text="None" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Phone Number</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryContactNum" runat="server" Text="None" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Address</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryAddress" runat="server" Text="None" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Birthday / Age</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryBirthday" runat="server" Text="Not specified" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Registered On</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryCreatedAt" runat="server" /></div>
                    </div>
                </div>

                <div class="summary-section-box">
                    <div class="summary-section-title">Personal Biography & Portfolio Intro</div>
                    <p style="font-size: 0.88rem; color: #334155; line-height: 1.55;">
                        <asp:Literal ID="litSummaryBio" runat="server" Text="No personal biography provided." />
                    </p>
                </div>

                <div class="summary-section-box">
                    <div class="summary-section-title">Educational Attainment</div>
                    <asp:Repeater ID="rptSummaryEducations" runat="server">
                        <HeaderTemplate><ul style="padding-left: 18px; font-size: 0.88rem;"></HeaderTemplate>
                        <ItemTemplate>
                            <li style="margin-bottom: 4px;">
                                <strong><%# Eval("CourseName") %></strong> at <%# Eval("University") %> 
                                <span style="color: var(--text-muted);">(<%# Eval("StartYear") %> - <%# Eval("EndYear") %>)</span>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate></ul></FooterTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoEducations" runat="server" Text="No education history recorded." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                </div>

                <div class="summary-section-box">
                    <div class="summary-section-title">Organizations & Affiliations</div>
                    <asp:Repeater ID="rptSummaryAffiliations" runat="server">
                        <HeaderTemplate><ul style="padding-left: 18px; font-size: 0.88rem;"></HeaderTemplate>
                        <ItemTemplate>
                            <li style="margin-bottom: 4px;">
                                <strong><%# Eval("Position") %></strong> at <%# Eval("OrganizationName") %> 
                                <span style="color: var(--text-muted);">(<%# FormatPeriod(Eval("StartYear"), Eval("EndYear")) %>)</span>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate></ul></FooterTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoAffiliations" runat="server" Text="No organization affiliations recorded." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                </div>

                <div class="form-row" style="margin-bottom: 14px;">
                    <div class="summary-section-box" style="margin-bottom: 0;">
                        <div class="summary-section-title">Skills</div>
                        <div class="summary-pill-list">
                            <asp:Repeater ID="rptSummarySkills" runat="server">
                                <ItemTemplate>
                                    <span class="summary-pill"><%# Eval("SkillName") %></span>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Label ID="lblNoSkills" runat="server" Text="No skills listed." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                        </div>
                    </div>

                    <div class="summary-section-box" style="margin-bottom: 0;">
                        <div class="summary-section-title">Hobbies</div>
                        <div class="summary-pill-list">
                            <asp:Repeater ID="rptSummaryHobbies" runat="server">
                                <ItemTemplate>
                                    <span class="summary-pill"><%# Eval("HobbyName") %></span>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Label ID="lblNoHobbies" runat="server" Text="No hobbies listed." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                        </div>
                    </div>
                </div>

                <div class="summary-section-box" style="margin-bottom: 0;">
                    <div class="summary-section-title">Social Links & Profiles</div>
                    <div class="summary-pill-list">
                        <asp:Repeater ID="rptSummarySocialLinks" runat="server">
                            <ItemTemplate>
                                <a href='<%# FormatSocialUrl(Eval("Link")) %>' target="_blank" rel="noopener noreferrer" class="summary-pill summary-pill-link" title='<%# Eval("Link") %>'>
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                                    <span><%# Eval("SocialLinkName") %></span>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblNoSocialLinks" runat="server" Text="No social links connected." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                    </div>
                </div>

                <div class="modal-actions" style="margin-top: 18px;">
                    <button type="button" id="btnSummaryStatusTrigger" runat="server" class="btn btn-sm" onclick="openStatusModalFromSummary()">
                        <asp:Literal ID="litSummaryStatusBtnText" runat="server" Text="Deactivate" />
                    </button>
                    
                    <asp:HyperLink ID="lnkSummaryPortfolio" runat="server" Target="_blank" CssClass="btn btn-solid btn-sm">
                        View Live Portfolio
                    </asp:HyperLink>

                    <button type="button" class="btn btn-outline btn-sm" onclick="openEditFromSummary()">
                        Account Settings
                    </button>

                    <!--<button type="button" class="btn btn-danger btn-sm" onclick="openDeleteModalFromSummary()">
                        Delete
                    </button>-->
                    
                    <asp:Button ID="btnCloseSummary" runat="server" Text="Close" CssClass="btn btn-outline btn-sm" OnClick="btnCloseSummary_Click" />
                </div>
            </div>
        </asp:Panel>

        <div class="modal-overlay" id="statusModal">
            <div class="modal-box" style="max-width: 480px; text-align: center;">
                <button type="button" class="close-modal-btn" onclick="closeStatusModal()">&times;</button>
                
                <div id="statusModalIconWrap" style="width: 60px; height: 60px; border-radius: 50%; border: 2.5px solid #000; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; background-color: #fee2e2;">
                    <svg id="statusModalIconDeactivate" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                    <svg id="statusModalIconActivate" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5" style="display: none;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>

                <h3 class="modal-title" id="statusModalTitle">Deactivate</h3>
                <p class="modal-desc" id="statusModalDesc" style="margin-bottom: 24px; line-height: 1.5; color: #3f3f46;">
                    Are you sure you want to change the status of this user account?
                </p>

                <asp:HiddenField ID="hfStatusUserId" runat="server" />
                <asp:HiddenField ID="hfStatusNewState" runat="server" />

                <div class="modal-actions" style="justify-content: center; border-top: none; padding-top: 0; margin-top: 10px; gap: 12px;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeStatusModal()" style="min-width: 100px;">
                        Cancel
                    </button>
                    <asp:Button ID="btnConfirmStatusAction" runat="server" Text="Confirm" CssClass="btn btn-danger btn-sm" OnClick="btnConfirmStatusAction_Click" style="min-width: 140px;" />
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="deleteModal">
            <div class="modal-box" style="max-width: 480px; text-align: center;">
                <button type="button" class="close-modal-btn" onclick="closeDeleteModal()">&times;</button>
                
                <div style="width: 60px; height: 60px; border-radius: 50%; border: 2.5px solid #000; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; background-color: #fee2e2;">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        <line x1="10" y1="11" x2="10" y2="17"></line>
                        <line x1="14" y1="11" x2="14" y2="17"></line>
                    </svg>
                </div>

                <h3 class="modal-title">Delete User Account</h3>
                <p class="modal-desc" id="deleteModalDesc" style="margin-bottom: 16px; line-height: 1.5; color: #3f3f46;">
                    Are you sure you want to permanently delete this user account?
                </p>

                <div style="background-color: #fff1f2; border: 2px solid #fecdd3; border-radius: 10px; padding: 12px 14px; margin-bottom: 20px; text-align: left; display: flex; gap: 10px; align-items: flex-start;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#e11d48" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0; margin-top: 1px;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    <div style="font-size: 0.82rem; color: #9f1239; line-height: 1.45;">
                        <strong style="font-weight: 700;">Warning:</strong> This action cannot be undone. All associated portfolios, educations, skills, affiliations, hobbies, and social links will be permanently erased.
                    </div>
                </div>

                <asp:HiddenField ID="hfDeleteUserId" runat="server" />

                <div class="modal-actions" style="justify-content: center; border-top: none; padding-top: 0; margin-top: 10px; gap: 12px;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeDeleteModal()" style="min-width: 100px;">
                        Cancel
                    </button>
                    <asp:Button ID="btnConfirmDeleteUser" runat="server" Text="Yes, Permanently Delete" CssClass="btn btn-danger btn-sm" OnClick="btnConfirmDeleteUser_Click" style="min-width: 170px;" />
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="addModal">
            <div class="modal-box">
                <button type="button" class="close-modal-btn" onclick="closeAddModal()">&times;</button>
                <h3 class="modal-title">Create User Account</h3>
                <p class="modal-desc">Provision a new account with specified administrative privileges.</p>

                <div class="form-row">
                    <div>
                        <label class="form-label">First Name</label>
                        <asp:TextBox ID="txtAddFirstName" runat="server" CssClass="form-control" placeholder="Jane" />
                    </div>
                    <div>
                        <label class="form-label">Last Name</label>
                        <asp:TextBox ID="txtAddLastName" runat="server" CssClass="form-control" placeholder="Doe" />
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <asp:TextBox ID="txtAddEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="jane.doe@example.com" />
                </div>

                <div class="form-group">
                    <label class="form-label">Initial Password</label>
                    <asp:TextBox ID="txtAddPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Min. 6 characters" />
                </div>

                <div class="form-group">
                    <label class="form-label">System Role</label>
                    <asp:DropDownList ID="ddlAddRole" runat="server" CssClass="form-control">
                        <asp:ListItem Value="User" Text="User (Standard Portfolio Owner)" />
                        <asp:ListItem Value="Admin" Text="Admin (Console & System Access)" />
                    </asp:DropDownList>
                </div>

                <label class="form-check">
                    <asp:CheckBox ID="chkAddIsActive" runat="server" Checked="true" />
                    Activate account immediately
                </label>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeAddModal()">Cancel</button>
                    <asp:Button ID="btnSaveNewUser" runat="server" Text="Create Account" CssClass="btn btn-solid btn-sm" OnClick="btnSaveNewUser_Click" />
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="editModal">
            <div class="modal-box">
                <button type="button" class="close-modal-btn" onclick="closeEditModal()">&times;</button>
                <h3 class="modal-title">Edit User Account</h3>
                <p class="modal-desc">Update credentials, system role, and access status.</p>

                <asp:HiddenField ID="hfEditUserId" runat="server" />

                <div class="form-row">
                    <div>
                        <label class="form-label">First Name</label>
                        <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" />
                    </div>
                    <div>
                        <label class="form-label">Last Name</label>
                        <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <asp:TextBox ID="txtEditEmail" runat="server" TextMode="Email" CssClass="form-control" />
                </div>

                <div class="form-group">
                    <label class="form-label">System Role</label>
                    <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-control">
                        <asp:ListItem Value="User" Text="User (Standard Portfolio Owner)" />
                        <asp:ListItem Value="Admin" Text="Admin (Console & System Access)" />
                    </asp:DropDownList>
                </div>

                <label class="form-check">
                    <asp:CheckBox ID="chkEditIsActive" runat="server" />
                    Account is active and permitted to login
                </label>

                <div style="margin-top: 16px; padding-top: 14px; border-top: 1.5px dashed #cbd5e1;">
                    <label class="form-label" style="display: flex; align-items: center; justify-content: space-between;">
                        <span>Reset / Change Password</span>
                        <span style="font-size: 0.76rem; font-weight: normal; color: var(--text-muted);">(Leave blank to keep unchanged)</span>
                    </label>
                    <div class="form-row" style="margin-bottom: 0;">
                        <div>
                            <asp:TextBox ID="txtEditNewPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="New password (min 6)" />
                        </div>
                        <div>
                            <asp:TextBox ID="txtEditConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Confirm new password" />
                        </div>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeEditModal()">Cancel</button>
                    <asp:Button ID="btnUpdateUser" runat="server" Text="Save Changes" CssClass="btn btn-solid btn-sm" OnClick="btnUpdateUser_Click" />
                </div>
            </div>
        </div>
    </form>

    <script>
        // Modal helpers
        function openAddModal() {
            document.getElementById('addModal').classList.add('active');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.remove('active');
        }

        function openEditModal(userId, firstName, lastName, email, role, isActive) {
            document.getElementById('<%= hfEditUserId.ClientID %>').value = userId;
            document.getElementById('<%= txtEditFirstName.ClientID %>').value = firstName;
            document.getElementById('<%= txtEditLastName.ClientID %>').value = lastName;
            document.getElementById('<%= txtEditEmail.ClientID %>').value = email;
            document.getElementById('<%= ddlEditRole.ClientID %>').value = role;
            document.getElementById('<%= chkEditIsActive.ClientID %>').checked = (isActive === true || isActive === 'true');
            document.getElementById('<%= txtEditNewPassword.ClientID %>').value = '';
            document.getElementById('<%= txtEditConfirmPassword.ClientID %>').value = '';
            document.getElementById('editModal').classList.add('active');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.remove('active');
        }

        function openEditFromSummary() {
            var userId = document.getElementById('<%= hfSummaryUserId.ClientID %>').value;
            var firstName = document.getElementById('<%= hfSummaryFirstName.ClientID %>').value;
            var lastName = document.getElementById('<%= hfSummaryLastName.ClientID %>').value;
            var email = document.getElementById('<%= hfSummaryEmailRaw.ClientID %>').value;
            var role = document.getElementById('<%= hfSummaryRoleRaw.ClientID %>').value;
            var isActive = document.getElementById('<%= hfSummaryCurrentStatus.ClientID %>').value;
            openEditModal(userId, firstName, lastName, email, role, isActive);
        }

        // Proper Status Modal handlers
        function openStatusModal(userId, fullName, email, isActive) {
            document.getElementById('<%= hfStatusUserId.ClientID %>').value = userId;
            const isCurrentlyActive = (isActive === true || isActive === 'true');
            const targetNewState = !isCurrentlyActive;
            document.getElementById('<%= hfStatusNewState.ClientID %>').value = targetNewState ? 'true' : 'false';

            const titleEl = document.getElementById('statusModalTitle');
            const descEl = document.getElementById('statusModalDesc');
            const iconDeactivate = document.getElementById('statusModalIconDeactivate');
            const iconActivate = document.getElementById('statusModalIconActivate');
            const iconWrap = document.getElementById('statusModalIconWrap');
            const confirmBtn = document.getElementById('<%= btnConfirmStatusAction.ClientID %>');

            if (isCurrentlyActive) {
                titleEl.textContent = 'Deactivate User Account';
                descEl.innerHTML = 'Are you sure you want to deactivate the account for <strong>' + fullName + '</strong> (' + email + ')?<br><br><span style="color: #dc2626; font-size: 0.82rem; font-weight: 600;">The user will be immediately barred from signing in until an administrator reactivates their account.</span>';
                iconWrap.style.backgroundColor = '#fee2e2';
                iconDeactivate.style.display = 'block';
                iconActivate.style.display = 'none';
                confirmBtn.className = 'btn btn-danger btn-sm';
                confirmBtn.value = 'Yes, Deactivate';
            } else {
                titleEl.textContent = 'Activate User Account';
                descEl.innerHTML = 'Are you sure you want to activate the account for <strong>' + fullName + '</strong> (' + email + ')?<br><br><span style="color: #16a34a; font-size: 0.82rem; font-weight: 600;">The user will be granted full access to sign in and update their portfolio.</span>';
                iconWrap.style.backgroundColor = '#dcfce7';
                iconDeactivate.style.display = 'none';
                iconActivate.style.display = 'block';
                confirmBtn.className = 'btn btn-success btn-sm';
                confirmBtn.value = 'Yes, Activate';
            }

            document.getElementById('statusModal').classList.add('active');
        }

        function closeStatusModal() {
            document.getElementById('statusModal').classList.remove('active');
        }

        function openStatusModalFromSummary() {
            const userId = document.getElementById('<%= hfSummaryUserId.ClientID %>').value;
            const firstName = document.getElementById('<%= hfSummaryFirstName.ClientID %>').value;
            const lastName = document.getElementById('<%= hfSummaryLastName.ClientID %>').value;
            const fullName = (firstName + ' ' + lastName).trim();
            const email = document.getElementById('<%= hfSummaryEmailRaw.ClientID %>').value;
            const isActive = document.getElementById('<%= hfSummaryCurrentStatus.ClientID %>').value;
            openStatusModal(userId, fullName, email, isActive);
        }

        // Proper Delete Modal handlers
        function openDeleteModal(userId, fullName, email) {
            document.getElementById('<%= hfDeleteUserId.ClientID %>').value = userId;
            const descEl = document.getElementById('deleteModalDesc');
            descEl.innerHTML = 'Are you sure you want to permanently delete the account for <strong>' + fullName + '</strong> (' + email + ')?';
            document.getElementById('deleteModal').classList.add('active');
        }

        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.remove('active');
        }

        function openDeleteModalFromSummary() {
            const userId = document.getElementById('<%= hfSummaryUserId.ClientID %>').value;
            const firstName = document.getElementById('<%= hfSummaryFirstName.ClientID %>').value;
            const lastName = document.getElementById('<%= hfSummaryLastName.ClientID %>').value;
            const fullName = (firstName + ' ' + lastName).trim();
            const email = document.getElementById('<%= hfSummaryEmailRaw.ClientID %>').value;
            openDeleteModal(userId, fullName, email);
        }

        // Close on escape key
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                closeAddModal();
                closeEditModal();
                closeStatusModal();
                closeDeleteModal();
            }
        });

        // Close modals on clicking overlay background
        window.addEventListener('click', function (e) {
            const addModal = document.getElementById('addModal');
            const editModal = document.getElementById('editModal');
            const statusModal = document.getElementById('statusModal');
            const deleteModal = document.getElementById('deleteModal');
            if (e.target === addModal) closeAddModal();
            if (e.target === editModal) closeEditModal();
            if (e.target === statusModal) closeStatusModal();
            if (e.target === deleteModal) closeDeleteModal();
        });

        function dismissToast(btn) {
            var toast = btn.closest('.toast-box');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(16px)';
                setTimeout(function () { toast.style.display = 'none'; }, 250);
            }
        }

        // Instant Automatic Client-Side Filtering for User Management
        function applyClientUserFilters() {
            var searchInput = document.getElementById('<%= txtSearch.ClientID %>') || document.getElementById('txtSearch');
            var statusSelect = document.getElementById('<%= ddlStatusFilter.ClientID %>') || document.getElementById('ddlStatusFilter');
            var roleSelect = document.getElementById('<%= ddlRoleFilter.ClientID %>') || document.getElementById('ddlRoleFilter');
            var noUsersNotice = document.getElementById('clientNoUsers');

            var query = (searchInput ? searchInput.value : '').trim().toLowerCase();
            var statusVal = (statusSelect ? statusSelect.value : '').trim().toLowerCase();
            var roleVal = (roleSelect ? roleSelect.value : '').trim().toLowerCase();

            var rows = document.querySelectorAll('.data-table tbody tr.user-data-row');
            var visibleCount = 0;

            rows.forEach(function (row) {
                var name = row.getAttribute('data-name') || '';
                var email = row.getAttribute('data-email') || '';
                var role = row.getAttribute('data-role') || '';
                var status = row.getAttribute('data-status') || '';

                var matchesQuery = !query || name.indexOf(query) !== -1 || email.indexOf(query) !== -1;
                var matchesStatus = !statusVal || status === statusVal;
                var matchesRole = !roleVal || role === roleVal;

                if (matchesQuery && matchesStatus && matchesRole) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            if (noUsersNotice) {
                noUsersNotice.style.display = (visibleCount === 0 && rows.length > 0) ? 'block' : 'none';
            }
        }

        function resetClientUserFilters() {
            var searchInput = document.getElementById('<%= txtSearch.ClientID %>') || document.getElementById('txtSearch');
            var statusSelect = document.getElementById('<%= ddlStatusFilter.ClientID %>') || document.getElementById('ddlStatusFilter');
            var roleSelect = document.getElementById('<%= ddlRoleFilter.ClientID %>') || document.getElementById('ddlRoleFilter');

            if (searchInput) searchInput.value = '';
            if (statusSelect) statusSelect.selectedIndex = 0;
            if (roleSelect) roleSelect.selectedIndex = 0;

            applyClientUserFilters();
        }

        // Auto-dismiss active toasts after 5 seconds and wire up automatic filtering
        window.addEventListener('DOMContentLoaded', function () {
            var activeToasts = document.querySelectorAll('.toast-box');
            activeToasts.forEach(function (t) {
                setTimeout(function () {
                    var btn = t.querySelector('.toast-close-btn');
                    if (btn) dismissToast(btn);
                }, 5000);
            });

            var searchInput = document.getElementById('<%= txtSearch.ClientID %>') || document.getElementById('txtSearch');
            var statusSelect = document.getElementById('<%= ddlStatusFilter.ClientID %>') || document.getElementById('ddlStatusFilter');
            var roleSelect = document.getElementById('<%= ddlRoleFilter.ClientID %>') || document.getElementById('ddlRoleFilter');

            if (searchInput) {
                searchInput.addEventListener('input', applyClientUserFilters);
                searchInput.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        applyClientUserFilters();
                        return false;
                    }
                });
            }
            if (statusSelect) {
                statusSelect.addEventListener('change', applyClientUserFilters);
            }
            if (roleSelect) {
                roleSelect.addEventListener('change', applyClientUserFilters);
            }
        });
    </script>
</body>
</html>
